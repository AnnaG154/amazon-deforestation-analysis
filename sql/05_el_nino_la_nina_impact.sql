-- Ten skrypt analizuje, w jaki sposób zjawiska klimatyczne (El Niño, La Niña) korelują z poziomem wylesiania w poszczególnych stanach i latach.
-- Wykorzystuje widoki: climate_events oraz deforestation_long_view

-- 1. Całkowita deforestacja według roku i stanu w czasie trwania każdego zjawiska klimatycznego
SELECT
  ce.phenomenon,
  ce.severity,
  d.year,
  d.state,
  SUM(d.deforestation) AS total_deforestation
FROM
  climate_events ce
JOIN
  deforestation_long_view d
    ON d.year BETWEEN ce."start year" AND ce."end year"
GROUP BY
  ce.phenomenon, ce.severity, d.year, d.state
ORDER BY
  ce.phenomenon, d.year, total_deforestation DESC;


-- 2. Średni poziom wylesiania w zależności od typu zjawiska klimatycznego (średnia ogólnokrajowa)
SELECT
  ce.phenomenon,
  ROUND(AVG(d.deforestation), 2) AS avg_deforestation
FROM
  climate_events ce
JOIN
  deforestation_long_view d
    ON d.year BETWEEN ce."start year" AND ce."end year"
GROUP BY
  ce.phenomenon
ORDER BY
  avg_deforestation DESC;
