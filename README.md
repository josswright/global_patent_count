# Global Patent Count

Quick code to process a CSV download of per-country monthly patent filings,
downloaded from Google’s BigQuery service, and plot the resulting time series.

## Manifest
 - `global_patent_counts.r` -- Processes, aggregates, and plots the patent data. Expects a file `monthly_country_patents.csv` in a `data/` subdirectory.
 - `patent_monthly_count.sql` -- Contains the SQL query to be run in Google’s BigQuery console against the patent publications database. The result should be downloaded in CSV format and placed in the `data/` subdirectory.

Note that running the SQL query requires an appropriate login and set of credentials for Google’s BigQuery service.

Output graph will be saved to the `output/` subdirectory.
