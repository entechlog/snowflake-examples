{{
  config(
    materialized="external_stage2table",
    url = "s3://" ~ var('s3_bucket') ~ "/cricsheet/all_match_data/",
    file_format = "(type = JSON)"
  )
}}

SELECT metadata$filename AS unique_id,
  metadata$file_last_modified AS updated_at,
  metadata$filename AS file_name,
	metadata$file_row_number AS file_row_number,
	metadata$file_content_key AS file_content_key,
	metadata$file_last_modified AS file_last_modified,
	metadata$start_scan_time AS start_scan_time,
	$1 AS match_data
FROM {{ external_stage() }}
