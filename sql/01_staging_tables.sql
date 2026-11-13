CREATE TABLE public.def_area (
    year INTEGER PRIMARY KEY,
    "AC" INTEGER,
    "AM" INTEGER,
    "AP" INTEGER,
    "MA" INTEGER,
    "MT" INTEGER,
    "PA" INTEGER,
    "RO" INTEGER,
    "RR" INTEGER,
    "TO" INTEGER,
    "AMZ_LEGAL" INTEGER
);

--Dane zostały zaimportowane ręcznie przez funkcję **DBeaver → Import Data**  
--z pliku `def_area_2004_2019_copy.csv (edycja nazw kolumny "Anos/Estados" na "year" 
--oraz "AMZ LEGAL" na "AMZ_Legal" 
--Plik znajduje się w folderze `data/processed/processed_for_import`.
--plik pod nazwą def_area.sql zawierający stworzoną tabelę został wyeksportowany do folderu `data/processed/processed_sql`.


CREATE TABLE public.fires_data (
    year INTEGER,
    month INTEGER,
    state VARCHAR(50),
    latitude DOUBLE PRECISION,
    longitude DOUBLE PRECISION,
    firespots INTEGER
);

--Dane zostały zaimportowane ręcznie przez funkcję **DBeaver → Import Data**  
--z pliku inpe_brazilian_amazon_fires_1999_2019_copy.csv  
--Plik znajduje się w folderze `data/processed/processed_for_import`.
--plik fires_data.sql zawierający stworzoną tabelę został wyeksportowany do folderu `data/processed/processed_sql`.


CREATE TABLE public.climate_events (
    "start year" INTEGER,
    "end year" INTEGER,
    "phenomenon" VARCHAR(20),
    "severity" VARCHAR(20)
);

--Dane zostały zaimportowane ręcznie przez funkcję **DBeaver → Import Data**  
--z pliku el_nino_la_nina_1999_2019_copy.csv  
--Plik znajduje się w folderze `data/processed/processed_for_import`.
--plik climate_events.sql zawierający stworzoną tabelę został wyeksportowany do folderu `data/processed/processed_sql`.

