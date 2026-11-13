--Sprawdzenie braków i błędów w tabeli def_area

--Czy są NULL-e w def_area?
SELECT * FROM def_area
WHERE year IS NULL
   OR "AC" IS NULL OR "AM" IS NULL OR "AP" IS NULL OR "MA" IS NULL
   OR "MT" IS NULL OR "PA" IS NULL OR "RO" IS NULL OR "RR" IS NULL
   OR "TO" IS NULL OR "AMZ_LEGAL" IS NULL;


--Czy są wartości ujemne?
SELECT * FROM def_area
WHERE "AC" < 0 OR "AM" < 0 OR "AP" < 0 OR "MA" < 0
   OR "MT" < 0 OR "PA" < 0 OR "RO" < 0 OR "RR" < 0
   OR "TO" < 0 OR "AMZ_LEGAL" < 0;

-----------------------------------------------------

-- Sprawdzenie braków i anomalii w climate_events

--Czy są NULL-e?
SELECT * FROM climate_events
WHERE "start year" IS NULL OR "end year" IS NULL
   OR phenomenon IS NULL OR severity IS NULL;

--Czy start_year <= end_year?
SELECT * FROM climate_events
WHERE "start year" > "end year";

--Czy są nietypowe wartości w phenomenon?
SELECT DISTINCT phenomenon FROM climate_events;

--Czy severity zawiera tylko znane wartości?
SELECT DISTINCT severity FROM climate_events;

-----------------------------------------------------

-- Sprawdzenie błędów i braków w fires_data

--Czy są NULL-e?
SELECT * FROM fires_data
WHERE year IS NULL OR month IS NULL OR state IS NULL
   OR latitude IS NULL OR longitude IS NULL OR firespots IS NULL;

--Czy są wartości ujemne lub miesiące spoza zakresu 1–12?
SELECT * FROM fires_data
WHERE firespots < 0 OR month NOT BETWEEN 1 AND 12;

-- Czy stany mają poprawne nazwy?
SELECT DISTINCT state FROM fires_data;

-- Porównanie nazw stanów między tabelą fires_data (kolumna "state")
-- a nazwami kolumn w tabeli def_area (reprezentującymi stany jako skróty)

-- Krok 1: Wyciągamy nazwy kolumn z def_area (stanowe)
SELECT column_name AS def_area_state
FROM information_schema.columns
WHERE table_name = 'def_area'
  AND column_name NOT IN ('year', 'amz_legal')
ORDER BY def_area_state;

-- w wyniku tego zapytania pojawizły sie dane wskazuące na duplikacje nazw kolumn 
--w def_area 

-- 🌐 Standaryzacja nazw kolumn: def_area_clean
CREATE OR REPLACE VIEW def_area_clean AS
SELECT
  year,
  "AC", "AM", "AP", "MA", "MT", "PA", "RO", "RR", "TO",
  COALESCE("AMZ_LEGAL", "AMZ LEGAL") AS amz_legal
FROM def_area
WHERE year IS NOT NULL;

-- Krok 2: Wyciągamy unikalne wartości z fires_data
SELECT DISTINCT state AS fires_data_state
FROM fires_data
ORDER BY fires_data_state;

-- Utworzenie widoku fires_data_mapped
-- Widok przekształca pełne nazwy stanów w tabeli fires_data
-- na skróty zgodne z widokiem def_area_clean (np. 'PARA' → 'PA'),
-- co umożliwia dalszą analizę i łączenie danych per stan.
-- 🔄 Widok standaryzujący nazwy stanów w fires_data
-- Pełne nazwy przekształcone do skrótów zgodnych z def_area_clean
CREATE OR REPLACE VIEW fires_data_mapped AS
SELECT
  CASE
    WHEN state = 'ACRE' THEN 'AC'
    WHEN state = 'AMAZONAS' THEN 'AM'
    WHEN state = 'AMAPA' THEN 'AP'
    WHEN state = 'MARANHAO' THEN 'MA'
    WHEN state = 'MATO GROSSO' THEN 'MT'
    WHEN state = 'PARA' THEN 'PA'
    WHEN state = 'RONDONIA' THEN 'RO'
    WHEN state = 'RORAIMA' THEN 'RR'
    WHEN state = 'TOCANTINS' THEN 'TO'
    ELSE state  
  END AS state,
  year,
  month,
  latitude,
  longitude,
  firespots
FROM fires_data;

-- Walidacja zakresu współrzędnych geograficznych (Amazonia Legalna)
-- Sprawdzenie minimalnych i maksymalnych wartości latitude oraz longitude
-- oraz weryfikacja, czy dane mieszczą się w zadanym obszarze:
-- Szerokość geograficzna:  -18.0 do 5.3
-- Długość geograficzna:    -74.0 do -44.0
SELECT
  MIN(latitude) AS min_latitude,
  MAX(latitude) AS max_latitude,
  MIN(longitude) AS min_longitude,
  MAX(longitude) AS max_longitude,
  CASE
    WHEN MIN(latitude) < -18.0 OR MAX(latitude) > 5.3 THEN 'Latitude OUT of range'
    ELSE 'Latitude OK'
  END AS latitude_status,
  CASE
    WHEN MIN(longitude) < -74.0 OR MAX(longitude) > -44.0 THEN 'Longitude OUT of range'
    ELSE 'Longitude OK'
  END AS longitude_status,
  (
    SELECT COUNT(*)
    FROM fires_data
    WHERE latitude NOT BETWEEN -18.0 AND 5.3
       OR longitude NOT BETWEEN -74.0 AND -44.0
  ) AS out_of_bounds_count
FROM fires_data_mapped;

