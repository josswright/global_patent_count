-- Select monthly counts of per-country articles
-- Designed for Google BigQuery 'patents-public-data'.
-- NB: "filing date" could sensibly be replaced with "priority date"
#standardSQL
SELECT month, country, COUNT(*) AS patent_count
FROM (
	SELECT country_code AS country, ROUND( filing_date, -2 ) AS month
	FROM `patents-public-data.patents.publications`
) as patents_count
GROUP BY month, country
ORDER BY month, patent_count DESC;
