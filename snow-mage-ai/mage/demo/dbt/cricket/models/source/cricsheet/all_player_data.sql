-- Mode is set to INSERT because COPY statement only supports 
-- simple SELECT from stage statements for import.
{{
    config(
        materialized="stage2table",
        url="s3://" ~ var("s3_bucket") ~ "/cricsheet/all_player_data/",
        file_format="(TYPE = CSV SKIP_HEADER = 1 TRIM_SPACE = TRUE ESCAPE_UNENCLOSED_FIELD = NONE)",
        mode="INSERT",
        tags=["source", "cricsheet"],
        pre_hook="{{ delete_data('FILE_LAST_MODIFIED_DT', var('batch_date'), this) }}",
    )
}}

select
    replace(
        metadata$filename, split_part(metadata$filename, '/', - 1), ''
    ) as file_path,
    split_part(metadata$filename, '/', - 1) as file_name,
    metadata$file_row_number as file_row_number,
    metadata$file_content_key as file_content_key,
    metadata$file_last_modified as file_last_modified_timestamp,
    try_to_date(to_varchar(metadata$file_last_modified)) as file_last_modified_dt,
    hour(metadata$file_last_modified) as file_last_modified_hour,
    hash($1) as row_content_key,
    metadata$start_scan_time as loaded_timestamp,
    '{{ this.name }}' as loaded_by,
    regexp_substr(metadata$filename, 'stream=([^/]+)', 1, 1, 'e') as event_name,
    $1 as identifier,
    $2 as name,
    $3 as unique_name,
    $4 as key_bcci,
    $5 as key_bcci_2,
    $6 as key_bigbash,
    $7 as key_cricbuzz,
    $8 as namekey_crichq,
    $9 as namekey_cricinfo,
    $10 as namekey_cricinfo_2,
    $11 as namekey_cricingif,
    $12 as namekey_cricketarchive,
    $13 as namekey_cricketarch
from {{ external_stage() }}
{% if not var("is_full_refresh") %}
    where date(file_last_modified_dt) = {{ "'" ~ var("batch_date") ~ "'" }}
{% endif %}
