USE DATABASE <database-name>;
USE SCHEMA <schema-name>;

SHOW STAGES;
DESC STAGE <stage-name>;
LIST @<stage-name>;

SELECT src.metadata$filename AS file_name,
	src.metadata$file_row_number AS file_row_number,
	src.metadata$file_content_key AS file_content_key,
	src.metadata$file_last_modified AS file_last_modified,
	src.metadata$start_scan_time,
	src.$1 AS cloudwatch_log
FROM @<stage-name> src;
