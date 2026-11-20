CREATE OR REPLACE TABLE raw_reproducciones AS
SELECT *
FROM read_csv_auto(?, header=True, all_varchar=True);