{# =============================================================================
   Platform-layer name builders - AR / FR / SVC_FR pattern
   -----------------------------------------------------------------------------
   DCM disallows {% import %}. Macros under sources/macros/ are auto-global -
   call by bare name.

   Naming conventions (env-first prefix kept per repo standard):

     Database          {ENV}_{PROJ}_{LAYER}_DB
     Warehouse         {ENV}_{PROJ}_{TOOL}_WH_{SIZE}

     Access Role       {ENV}_{PROJ}_{LAYER}_RO_AR / _RW_AR     (env-scoped, owned by platform)
     Functional Role   {PROJ}_{ROLE}_FR                         (account-level, no env)
     Service Func Role {ENV}_{PROJ}_{TOOL}_SVC_FR              (env-scoped, per tool)

     Team DCM deployer SVC_{PROJ}_SNOW_DCM_ROLE                 (special bootstrap role)
     Team DCM user     SVC_{PROJ}_SNOW_DCM_USER

   ARs hold FUTURE grants on the database. FRs/SVC_FRs are granted ARs (never
   granted directly to objects). Users are granted FRs; service users are
   granted SVC_FRs. The team DCM role owns the DBs (transferred from platform)
   so it can create/own schemas, tables, views inside.
   ============================================================================= #}

{# ─── Object names ─── #}

{% macro db_name(team, layer) -%}
{{ env_code | upper }}_{{ team | upper }}_{{ layer | upper }}_DB
{%- endmacro %}

{# ─── Role names ─── #}

{# Access role per DB-layer: {ENV}_{TEAM}_{LAYER}_RO_AR / _RW_AR #}
{% macro ar_name(team, layer, access) -%}
{{ env_code | upper }}_{{ team | upper }}_{{ layer | upper }}_{{ access | upper }}_AR
{%- endmacro %}

{# Functional role per job-function: {TEAM}_{ROLE}_FR  (no env — spans all envs) #}
{% macro fr_name(team, role) -%}
{{ team | upper }}_{{ role | upper }}_FR
{%- endmacro %}

{# Service-functional role per tool, per env: {ENV}_{TEAM}_{TOOL}_SVC_FR #}
{% macro svc_fr_name(team, tool) -%}
{{ env_code | upper }}_{{ team | upper }}_{{ tool | upper }}_SVC_FR
{%- endmacro %}

{# Team DCM deployer role (one per team, no env — manages all team envs) #}
{% macro team_dcm_role(team) -%}
SVC_{{ team | upper }}_SNOW_DCM_ROLE
{%- endmacro %}

{# Team DCM deployer user — created out-of-band, granted role via DCM #}
{% macro team_dcm_user(team) -%}
SVC_{{ team | upper }}_SNOW_DCM_USER
{%- endmacro %}
