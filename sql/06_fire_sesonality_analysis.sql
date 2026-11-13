SELECT
  year,
  month,
  state,
  SUM(firespots) AS total_firespots
FROM
  fires_data_mapped
GROUP BY
  year, month, state
ORDER BY
  year, month;
