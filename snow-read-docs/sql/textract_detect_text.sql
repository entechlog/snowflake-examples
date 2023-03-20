WITH get_all_blocks
AS (
	SELECT src.metadata$filename AS file_name,
		src.metadata$file_row_number AS file_row_number,
		src.metadata$file_content_key AS file_content_key,
		src.metadata$file_last_modified AS file_last_modified,
		src.metadata$start_scan_time,
		src.$1 AS textract_response,
		blk.value: BlockType::VARCHAR AS block_type,
		blk.value: TEXT::VARCHAR AS block_text,
		blk.value::VARIANT AS block,
		rel.value::VARIANT AS relation
	FROM @DEMO_S3_STG(pattern = > '.*_detect_text_response.json') src,
		lateral flatten(input = > $1 :Blocks, OUTER = > true) blk,
		lateral flatten(input = > blk.value: Relationships, OUTER = > true) rel
	)
SELECT file_name,
	file_row_number,
	file_content_key,
	file_last_modified,
	block_type,
	block_text,
	block
FROM get_all_blocks
WHERE block_type = 'LINE';



SELECT src.metadata$filename AS file_name,
	src.METADATA$FILE_ROW_NUMBER AS file_row_number,
	src.METADATA$FILE_CONTENT_KEY AS file_content_key,
	src.METADATA$FILE_LAST_MODIFIED AS file_last_modified,
	src.METADATA$START_SCAN_TIME,
	src.$1 AS textract_response
FROM @DEMO_S3_STG(pattern = > '.*_detect_text_parsed_response.json') src;


SELECT DISTINCT $1:"Line 0"::VARCHAR as invoice_to,
$1:"Line 1"||$1:"Line 2"::VARCHAR as invoice_number,
$1:"Line 4"::VARCHAR as invoice_date,
$1:"Line 7"::VARCHAR as invoice_balance_due
FROM @DEMO_S3_STG(pattern => '.*_detect_text_parsed_response.json');