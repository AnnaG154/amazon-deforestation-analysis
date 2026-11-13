
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




