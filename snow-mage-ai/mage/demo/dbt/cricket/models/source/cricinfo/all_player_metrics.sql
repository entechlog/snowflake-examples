-- Mode is set to INSERT because COPY statement only supports 
-- simple SELECT from stage statements for import.

{{
    config(
        materialized="stage2table",
        url="s3://" ~ var("s3_bucket") ~ "/cricinfo/player_metrics/",
        file_format="(type = JSON)",
        mode="INSERT",
        tags=["source", "cricinfo"],
        pre_hook="{{ delete_data('FILE_LAST_MODIFIED_DT', var('batch_cycle_date'), this) }}",
    )
}}

select
    replace(
        metadata$filename, split_part(metadata$filename, '/', -1), ''
    ) as file_path,
    split_part(metadata$filename, '/', -1) as file_name,
    metadata$file_row_number as file_row_number,
    metadata$file_content_key as file_content_key,
    metadata$file_last_modified as file_last_modified_timestamp,
    try_to_date(to_varchar(metadata$file_last_modified)) as file_last_modified_dt,
    hour(metadata$file_last_modified) as file_last_modified_hour,
    metadata$start_scan_time as loaded_timestamp,
    '{{ this.name }}' as loaded_by,
    $1:player_id::varchar as player_id,
    $1:player_code::varchar as player_code,
    $1:player_name::varchar as player_name,
    $1:tests::variant as test_summary,
    $1:odis::variant as odi_summary,
    $1:t20s::variant as t20_summary
from {{ external_stage() }}  (PATTERN => '.*[.]json')
{{ filter_data(src_column_key = 'DATE(FILE_LAST_MODIFIED_DT)',src_operator='=',src_column_val="'" ~ var("batch_cycle_date") ~ "'" )}}