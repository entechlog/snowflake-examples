-- Read RAW response from textract 

WITH col_key
AS (
	SELECT DISTINCT src.metadata$filename AS file_name,
		tbl.KEY AS table_name,
		rw.KEY AS row_name,
		cl.KEY AS column_name,
		cl.value::VARCHAR AS column_value
	FROM @DEMO_S3_STG(pattern => '.*_analyze_text_parsed_response.json') src,
		lateral flatten(input => src.$1 [1] ['tables']::VARIANT, OUTER => true) tbl,
		lateral flatten(input => tbl.value::VARIANT, OUTER => true) rw,
		lateral flatten(input => rw.value::VARIANT, OUTER => true) cl
	WHERE table_name = 'table_1'
		AND row_name = 'row_0'
		AND column_value IS NOT NULL
	ORDER BY table_name,
		row_name,
		column_name ASC
	),
col_value
AS (
	SELECT DISTINCT src.metadata$filename AS file_name,
		tbl.KEY AS table_name,
		rw.KEY AS row_name,
		cl.KEY AS column_name,
		cl.value::VARCHAR AS column_value
	FROM @DEMO_S3_STG(pattern => '.*_analyze_text_parsed_response.json') src,
		lateral flatten(input => src.$1 [1] ['tables']::VARIANT, OUTER => true) tbl,
		lateral flatten(input => tbl.value::VARIANT, OUTER => true) rw,
		lateral flatten(input => rw.value::VARIANT, OUTER => true) cl
	WHERE table_name = 'table_1'
		AND row_name <> 'row_0'
		AND column_value IS NOT NULL
	ORDER BY table_name,
		row_name,
		column_name ASC
	),
col_key_and_val
AS (
	SELECT cv.file_name,
		cv.table_name,
		cv.row_name,
		cv.column_name,
		ck.column_value AS column_key,
		cv.column_value
	FROM col_key ck
	INNER JOIN col_value cv ON ck.table_name = cv.table_name
		AND ck.column_name = cv.column_name
	)
SELECT file_name,
	MAX(CASE 
			WHEN UPPER(TRIM(COLUMN_KEY)) IN (UPPER('Item'))
				THEN TRIM(COLUMN_VALUE)
			END) AS item,
	MAX(CASE 
			WHEN UPPER(TRIM(COLUMN_KEY)) IN (UPPER('Rate'))
				THEN TRIM(COLUMN_VALUE)
			END) AS rate,
	MAX(CASE 
			WHEN UPPER(TRIM(COLUMN_KEY)) IN (UPPER('Quantity'))
				THEN TRIM(COLUMN_VALUE)
			END) AS quantity,
	MAX(CASE 
			WHEN UPPER(TRIM(COLUMN_KEY)) IN (UPPER('Amount'))
				THEN TRIM(COLUMN_VALUE)
			END) AS amount
FROM col_key_and_val
GROUP BY file_name,
	table_name,
	row_name
HAVING item IS NOT NULL
	AND item <> ''
