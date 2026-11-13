


select * from climate_events ce;

select * from fires_data_mapped fdm;

--To zapytanie pokazuje sumaryczną liczbę pożarów podczas wszystkich 
--zjawisk El Niño i wszystkich La Niña. Nie rozróżnia stanów ani nasilenia zjawisk
SELECT
    ce.phenomenon,
    SUM(fd.firespots) AS total_fires
FROM
    climate_events ce
JOIN
    fires_data_mapped fd
        ON fd.year BETWEEN ce."start year" AND ce."end year"
GROUP BY
    ce.phenomenon;

--To zapytanie pokazuje, jak liczba pożarów
-- zmieniała się w zależności od siły zjawiska klimatycznego 
--(np. słabe, umiarkowane, silne El Niño / La Niña)
SELECT
    ce.phenomenon,
    ce.severity,
    SUM(fd.firespots) AS total_fires
FROM
    climate_events ce
JOIN
    fires_data_mapped fd
        ON fd.year BETWEEN ce."start year" AND ce."end year"
GROUP BY
    ce.phenomenon, ce.severity
ORDER BY
    ce.phenomenon, ce.severity;

--To zapyatnie pokazuje jak jednocześnie wyglądały liczba pożarów i tempo 
--wycinki w całej Amazonii Legalnej podczas poszczególnych zjawisk klimatycznych
SELECT
    ce.phenomenon,
    ce.severity,
    SUM(fd.firespots) AS total_fires,
    SUM(dl.amz_legal) AS total_deforestation
FROM
    climate_events ce
JOIN
    fires_data_mapped fd
        ON fd.year BETWEEN ce."start year" AND ce."end year"
JOIN
    deforestation_long_view dl
        ON dl.year = fd.year  -- bez warunku state = 'AMZ_LEGAL'
GROUP BY
    ce.phenomenon, ce.severity
ORDER BY
    ce.phenomenon, ce.severity;

--ta kwerenda daje możliwość analizy dla każdego stanu osobno — można wychwycić, 
--czy np. w niektórych stanach pożary/wycinka szczególnie nasilały się
-- w trakcie określonych zjawisk
SELECT
    ce.phenomenon,
    ce.severity,
    fd.state,
    SUM(fd.firespots) AS total_fires,
    SUM(dl.deforestation) AS total_deforestation
FROM
    climate_events ce
JOIN
    fires_data_mapped fd
        ON fd.year BETWEEN ce."start year" AND ce."end year"
JOIN
    deforestation_long_view dl
        ON dl.year = fd.year AND dl.state = fd.state
GROUP BY
    ce.phenomenon, ce.severity, fd.state
ORDER BY
    ce.phenomenon, ce.severity, fd.state;


-- Kwerenda zwraca liczbę pożarów oraz powierzchnię wylesienia
-- dla każdego stanu, roku, punktu geograficznego oraz okresu El Niño/La Niña.
-- Pozwala analizować powiązania między pożarami, deforestacją i zjawiskami klimatycznymi w czasie i przestrzeni.
-- Wynik można wykorzystać do budowy mapy cieplnej oraz analizy trendów w Tableau.
SELECT
    ce.phenomenon,
    ce.severity,
    ce."start year" AS climate_start_year,
    ce."end year" AS climate_end_year,
    fd.state,
    fd.year,
    fd.latitude,
    fd.longitude,
    SUM(fd.firespots) AS total_fires,
    MAX(dl.deforestation) AS total_deforestation
FROM
    climate_events ce
JOIN
    fires_data_mapped fd
        ON fd.year BETWEEN ce."start year" AND ce."end year"
JOIN
    deforestation_long_view dl
        ON dl.year = fd.year AND dl.state = fd.state
GROUP BY
    ce.phenomenon,
    ce.severity,
    ce."start year",
    ce."end year",
    fd.state,
    fd.year,
    fd.latitude,
    fd.longitude
ORDER BY
    ce.phenomenon, ce.severity, fd.state, fd.year, total_fires DESC;
