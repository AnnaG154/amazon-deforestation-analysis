
-- UWAGA: Wcześniejsza wersja widoku `def_area_clean` zawierała błędną kolumnę `"Ano/Estados"` powodującą NULL-e w kolumnie `year`.
-- Widok został poprawiony 15.05.2025 i zawiera teraz poprawne dane z kolumny `year`.
-- Widok opiera się także na COALESCE dla `AMZ_LEGAL` i `AMZ LEGAL`.
-- Poprawka znajduje się w pliku: 02_data_cleaning.sql

-- Podgląd danych
SELECT * FROM def_area_clean LIMIT 5;

-- Ogólny pogląd sytuacyjny – skala wylesienia (total_deforestation) w kolejnych latach
SELECT
  year,
  amz_legal AS total_deforestation
FROM def_area_clean
ORDER BY year;

-- Porównanie stanów – który był najbardziej, a który najmniej dotknięty (suma deforestacji 2004–2019)
SELECT
  state,
  SUM(deforestation) AS total_deforestation
FROM (
  SELECT 'AC' AS state, SUM("AC") AS deforestation FROM def_area_clean
  UNION ALL
  SELECT 'AM', SUM("AM") FROM def_area_clean
  UNION ALL
  SELECT 'AP', SUM("AP") FROM def_area_clean
  UNION ALL
  SELECT 'MA', SUM("MA") FROM def_area_clean
  UNION ALL
  SELECT 'MT', SUM("MT") FROM def_area_clean
  UNION ALL
  SELECT 'PA', SUM("PA") FROM def_area_clean
  UNION ALL
  SELECT 'RO', SUM("RO") FROM def_area_clean
  UNION ALL
  SELECT 'RR', SUM("RR") FROM def_area_clean
  UNION ALL
  SELECT 'TO', SUM("TO") FROM def_area_clean
) AS all_states
GROUP BY state
ORDER BY total_deforestation DESC;

-- Rok i stan z największą punktową deforestacją w całym okresie
SELECT *
FROM (
  SELECT year, 'AC' AS state, "AC" AS deforestation FROM def_area_clean
  UNION ALL
  SELECT year, 'AM', "AM" FROM def_area_clean
  UNION ALL
  SELECT year, 'AP', "AP" FROM def_area_clean
  UNION ALL
  SELECT year, 'MA', "MA" FROM def_area_clean
  UNION ALL
  SELECT year, 'MT', "MT" FROM def_area_clean
  UNION ALL
  SELECT year, 'PA', "PA" FROM def_area_clean
  UNION ALL
  SELECT year, 'RO', "RO" FROM def_area_clean
  UNION ALL
  SELECT year, 'RR', "RR" FROM def_area_clean
  UNION ALL
  SELECT year, 'TO', "TO" FROM def_area_clean
) AS deforest_by_state_year
ORDER BY deforestation DESC
LIMIT 1;

-- Rok i stan z najmniejszą punktową deforestacją (dla porównania)
SELECT *
FROM (
  SELECT year, 'AC' AS state, "AC" AS deforestation FROM def_area_clean
  UNION ALL
  SELECT year, 'AM', "AM" FROM def_area_clean
  UNION ALL
  SELECT year, 'AP', "AP" FROM def_area_clean
  UNION ALL
  SELECT year, 'MA', "MA" FROM def_area_clean
  UNION ALL
  SELECT year, 'MT', "MT" FROM def_area_clean
  UNION ALL
  SELECT year, 'PA', "PA" FROM def_area_clean
  UNION ALL
  SELECT year, 'RO', "RO" FROM def_area_clean
  UNION ALL
  SELECT year, 'RR', "RR" FROM def_area_clean
  UNION ALL
  SELECT year, 'TO', "TO" FROM def_area_clean
) AS deforest_by_state_year
ORDER BY deforestation ASC
LIMIT 1;

--Widok pomocniczy do wykresu łączonego w Tableau: słupki = deforestacja stanów, linia = łączna amz_legal
--Widok deforestation_long_view umożliwia analizę porównawczą między stanami oraz odniesienie do łącznej deforestacji.
CREATE OR REPLACE VIEW deforestation_long_view AS
SELECT
  year,
  'AC' AS state,
  "AC" AS deforestation,
  amz_legal
FROM def_area_clean
UNION ALL
SELECT year, 'AM', "AM", amz_legal FROM def_area_clean
UNION ALL
SELECT year, 'AP', "AP", amz_legal FROM def_area_clean
UNION ALL
SELECT year, 'MA', "MA", amz_legal FROM def_area_clean
UNION ALL
SELECT year, 'MT', "MT", amz_legal FROM def_area_clean
UNION ALL
SELECT year, 'PA', "PA", amz_legal FROM def_area_clean
UNION ALL
SELECT year, 'RO', "RO", amz_legal FROM def_area_clean
UNION ALL
SELECT year, 'RR', "RR", amz_legal FROM def_area_clean
UNION ALL
SELECT year, 'TO', "TO", amz_legal FROM def_area_clean;

select * from deforestation_long_view;
