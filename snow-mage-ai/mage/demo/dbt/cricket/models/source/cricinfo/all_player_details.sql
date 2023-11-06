-- Mode is set to INSERT because COPY statement only supports 
-- simple SELECT from stage statements for import.
{{
    config(
        materialized="stage2table",
        url="s3://" ~ var("s3_bucket") ~ "/cricinfo/player_details/",
        file_format="(type = JSON)",
        mode="INSERT",
        tags=["source", "cricinfo"],
        pre_hook="{{ delete_data('FILE_LAST_MODIFIED_DT', var('batch_date'), this) }}",
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
    pd.$1:player_id::varchar as player_id,
    pd.$1:player_code::varchar as player_code,
    pd.$1:player_name::varchar as player_name,
    pd.$1:born::varchar as born,
    pd.$1:batting_style::varchar as batting_style,
    pd.$1:bowling_style::varchar as bowling_style,
    pd.$1:playing_role::varchar as playing_role,
    pd.$1:teams::variant as teams
from {{ external_stage() }} pd
{% if not var("is_full_refresh") %}
    where date(file_last_modified_dt) = {{ "'" ~ var("batch_date") ~ "'" }}
{% endif %}
