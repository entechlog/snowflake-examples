{# =============================================================================
   Team-layer name builders — SALES (hybrid Pattern C)
   -----------------------------------------------------------------------------
   DCM disallows {% import %}. Macros under sources/macros/ are auto-global —
   call by bare name. Macros are NOT shared across DCM projects, so this file
   exists in BOTH platform/dcm/sources/macros/ and teams/sales/dcm/sources/
   macros/ — keep them in sync if the conventions change.

   In Pattern C, the team layer only declares OBJECTS (schemas, tables, views,
   dynamic tables) inside DBs the team owns. ALL grants are handled by the
   PLATFORM layer's AR/FR/SVC_FR machinery — that's why there are no role or
   grant-pattern macros here.
   ============================================================================= #}

{# Database name: {ENV}_{TEAM}_{LAYER}_DB — team-owned (transferred from PLATFORM) #}
{% macro db_name(layer) -%}
{{ env_code | upper }}_{{ team_name | upper }}_{{ layer | upper }}_DB
{%- endmacro %}

{# Warehouse name: {ENV}_{TEAM}_{TOOL}_WH_{SIZE} — team-owned (transferred from PLATFORM) #}
{# Used when team-layer DDL references the WH (e.g., dynamic table's WAREHOUSE clause). #}
{% macro wh_name(tool, size_code='XS') -%}
{{ env_code | upper }}_{{ team_name | upper }}_{{ tool | upper }}_WH_{{ size_code | upper }}
{%- endmacro %}
