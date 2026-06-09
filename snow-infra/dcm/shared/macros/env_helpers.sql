{# =============================================================================
   CANONICAL macro file — single source of truth for object naming.
   -----------------------------------------------------------------------------
   This file lives in snow-infra/dcm/shared/macros/. Both platform/dcm/sources/
   macros/ and teams/<team>/dcm/sources/macros/ are populated FROM HERE by
   running scripts/sync_macros.sh. DO NOT edit the synced copies directly —
   edit this file and re-sync.

   All macros take team as an explicit parameter so the file is identical
   across all projects (platform loops over teams; team layers pass their
   team_name from manifest defaults).

   DCM disallows {% import %}. Macros under sources/macros/ are auto-global —
   call by bare name.
   ============================================================================= #}

{# Database name: {ENV}_{TEAM}_{LAYER}_DB #}
{% macro db_name(team, layer) -%}
{{ env_code | upper }}_{{ team | upper }}_{{ layer | upper }}_DB
{%- endmacro %}

{# Warehouse name: {ENV}_{TEAM}_{TOOL}_WH_{SIZE} #}
{% macro wh_name(team, tool, size_code='XS') -%}
{{ env_code | upper }}_{{ team | upper }}_{{ tool | upper }}_WH_{{ size_code | upper }}
{%- endmacro %}

{# Access role per DB-layer: {ENV}_{TEAM}_{LAYER}_RO_AR / _RW_AR #}
{% macro ar_name(team, layer, access) -%}
{{ env_code | upper }}_{{ team | upper }}_{{ layer | upper }}_{{ access | upper }}_AR
{%- endmacro %}

{# Functional role per job-function: {TEAM}_{ROLE}_FR  (no env — spans envs) #}
{% macro fr_name(team, role) -%}
{{ team | upper }}_{{ role | upper }}_FR
{%- endmacro %}

{# Service-functional role per tool, per env: {ENV}_{TEAM}_{TOOL}_SVC_FR #}
{% macro svc_fr_name(team, tool) -%}
{{ env_code | upper }}_{{ team | upper }}_{{ tool | upper }}_SVC_FR
{%- endmacro %}

{# Team DCM deployer role (one per team, no env — manages all team envs) #}
{% macro team_dcm_role(team) -%}
SVC_{{ team | upper }}_DCM_ROLE
{%- endmacro %}

{# Team DCM deployer user — created out-of-band, granted role via DCM #}
{% macro team_dcm_user(team) -%}
SVC_{{ team | upper }}_DCM_USER
{%- endmacro %}
