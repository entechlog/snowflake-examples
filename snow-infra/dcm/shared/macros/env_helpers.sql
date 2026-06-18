{# =============================================================================
   CANONICAL macro file — single source of truth for object naming.
   -----------------------------------------------------------------------------
   Lives in snow-infra/dcm/shared/macros/. Synced into every project's
   sources/macros/ by scripts/sync_macros.sh — do not edit the synced copies.

   DCM disallows {% import %}. Macros under sources/macros/ are auto-global —
   call by bare name.

   This demo only ships the macros it uses. The full naming standard
   (WH_, _AR, _FR, _SVC_FR etc.) is documented in the README so teams
   can declare their own RBAC + warehouses in their team DCM project.
   ============================================================================= #}

{# Database name: {ENV}_{TEAM}_{LAYER}_DB #}
{% macro db_name(team, layer) -%}
{{ env_code | upper }}_{{ team | upper }}_{{ layer | upper }}_DB
{%- endmacro %}

{# Team DCM deployer role (one per team, no env — spans all envs) #}
{% macro team_dcm_role(team) -%}
SVC_{{ team | upper }}_DCM_ROLE
{%- endmacro %}

{# Team DCM deployer user — created out-of-band, granted role via DCM #}
{% macro team_dcm_user(team) -%}
SVC_{{ team | upper }}_DCM_USER
{%- endmacro %}
