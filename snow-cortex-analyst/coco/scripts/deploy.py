#!/usr/bin/env python3
"""
Deploy and manage Cortex Analyst semantic views and agents from YAML files.

YAML files are the single source of truth. This script handles the full
lifecycle: deploy to Snowflake, pull UI edits back to YAML, and check
drift between local files and deployed objects.

Modes:
    python deploy.py                        # Deploy all views then agents
    python deploy.py --dry-run              # Print SQL without executing
    python deploy.py --pull                 # Export Snowflake → YAML files
    python deploy.py --status               # Compare local vs deployed

Filters (work with all modes):
    python deploy.py --views v1 v2          # Only these views
    python deploy.py --agents a1            # Only this agent
    python deploy.py --pull --agents a1     # Pull only this agent

Options:
    python deploy.py --schema SEMANTIC      # Target schema (default: SEMANTIC)

Environment variables:
    ENV_CODE              Environment code (dev/stg/prd, default: dev)
    PROJ_CODE             Project code (default: entechlog)
    SNOWFLAKE_ACCOUNT     Snowflake account identifier
    SNOWFLAKE_USER        Snowflake username
    SNOWFLAKE_PASSWORD    Password (for password auth)
    SNOWFLAKE_AUTHENTICATOR  Auth method: snowflake (default), externalbrowser,
                             snowflake_jwt (key-pair)
    SNOWFLAKE_PRIVATE_KEY_PATH  Path to private key file (for key-pair auth)
    SNOWFLAKE_ROLE        Override role (default: {ENV}_SVC_{PROJ}_SNOW_DBT_ROLE)
    SNOWFLAKE_WAREHOUSE   Override warehouse (default: {ENV}_{PROJ}_DBT_WH_XS)
"""

import os
import re
import sys
import json
import yaml
import glob
import argparse
import logging

logging.basicConfig(
    format="%(asctime)s  %(message)s",
    datefmt="%H:%M:%S",
    level=logging.INFO,
)
log = logging.getLogger("deploy")


# ---------------------------------------------------------------------------
# YAML formatting helpers
# ---------------------------------------------------------------------------

class _LiteralStr(str):
    """String subclass that forces YAML block literal style (|)."""
    pass


def _literal_representer(dumper, data):
    style = "|" if "\n" in data else None
    return dumper.represent_scalar("tag:yaml.org,2002:str", data, style=style)


def _str_representer(dumper, data):
    """Use block literal for multi-line strings, plain/quoted for single-line."""
    if "\n" in data:
        return dumper.represent_scalar("tag:yaml.org,2002:str", data, style="|")
    return dumper.represent_scalar("tag:yaml.org,2002:str", data)


class _CleanDumper(yaml.SafeDumper):
    """Custom YAML dumper that uses block style for multi-line strings."""
    pass

_CleanDumper.add_representer(str, _str_representer)
_CleanDumper.add_representer(_LiteralStr, _literal_representer)


# ---------------------------------------------------------------------------
# Semantic view YAML normalization
# ---------------------------------------------------------------------------

_DTYPE_SIMPLIFY = {
    re.compile(r"^VARCHAR\(\d+\)$", re.IGNORECASE): "VARCHAR",
    re.compile(r"^NUMBER\(38,\s*0\)$", re.IGNORECASE): "NUMBER",
    re.compile(r"^FLOAT$", re.IGNORECASE): "NUMBER",
}

_TABLE_SECTION_ORDER = [
    "name", "description", "base_table",
    "time_dimensions", "dimensions", "facts", "metrics",
]

_VQ_FIELD_ORDER = ["name", "question", "sql", "use_as_onboarding_question"]


def _simplify_dtype(dtype):
    if not isinstance(dtype, str):
        return dtype
    for pattern, replacement in _DTYPE_SIMPLIFY.items():
        if pattern.match(dtype):
            return replacement
    return dtype


def _normalize_column(col):
    if "name" in col:
        col["name"] = col["name"].lower()
    if "data_type" in col:
        col["data_type"] = _simplify_dtype(col["data_type"])
    col.pop("access_modifier", None)
    return col


def _reorder_table(table):
    ordered = {}
    for key in _TABLE_SECTION_ORDER:
        if key in table:
            ordered[key] = table[key]
    for key in table:
        if key not in ordered:
            ordered[key] = table[key]
    return ordered


def _normalize_semantic_view_yaml(yaml_str, database):
    """Normalize Snowflake-canonical YAML to match hand-written convention."""
    data = yaml.safe_load(yaml_str)

    if "name" in data:
        data["name"] = data["name"].lower()

    for table in data.get("tables", []):
        if "name" in table:
            table["name"] = table["name"].lower()
        bt = table.get("base_table", {})
        if bt.get("database") == database:
            bt["database"] = "__DATABASE__"
        for section in ("time_dimensions", "dimensions", "facts", "metrics"):
            cols = table.get(section, [])
            table[section] = sorted(
                [_normalize_column(c) for c in cols],
                key=lambda c: c.get("name", ""),
            )
            if not table[section]:
                del table[section]
        idx = data["tables"].index(table)
        data["tables"][idx] = _reorder_table(table)

    vqs = data.get("verified_queries", [])
    reordered_vqs = []
    for vq in vqs:
        if "name" in vq:
            vq["name"] = vq["name"].lower()
        ordered_vq = {}
        for key in _VQ_FIELD_ORDER:
            if key in vq:
                ordered_vq[key] = vq[key]
        for key in vq:
            if key not in ordered_vq:
                ordered_vq[key] = vq[key]
        reordered_vqs.append(ordered_vq)
    data["verified_queries"] = sorted(reordered_vqs, key=lambda q: q.get("name", ""))

    return yaml.dump(
        data, Dumper=_CleanDumper, default_flow_style=False,
        sort_keys=False, allow_unicode=True, width=120,
    )


# ---------------------------------------------------------------------------
# Environment & Connection
# ---------------------------------------------------------------------------

def get_env():
    env_code = os.environ.get("ENV_CODE", "dev").strip().upper()
    proj_code = os.environ.get("PROJ_CODE", "entechlog").strip().upper()
    database = f"{env_code}_{proj_code}_DW_DB"
    return env_code, proj_code, database


def get_connection():
    env_code, proj_code, database = get_env()
    import snowflake.connector

    default_role = f"{env_code}_SVC_{proj_code}_SNOW_DBT_ROLE"
    default_warehouse = f"{env_code}_{proj_code}_DBT_WH_XS"
    authenticator = os.environ.get("SNOWFLAKE_AUTHENTICATOR", "snowflake")

    conn_params = {
        "account": os.environ["SNOWFLAKE_ACCOUNT"],
        "user": os.environ["SNOWFLAKE_USER"],
        "role": os.environ.get("SNOWFLAKE_ROLE", default_role),
        "warehouse": os.environ.get("SNOWFLAKE_WAREHOUSE", default_warehouse),
        "database": database,
        "schema": "SEMANTIC",
    }

    if authenticator == "externalbrowser":
        conn_params["authenticator"] = "externalbrowser"
    elif authenticator == "snowflake_jwt":
        key_path = os.environ.get("SNOWFLAKE_PRIVATE_KEY_PATH", "")
        if not key_path:
            log.error("SNOWFLAKE_PRIVATE_KEY_PATH required for key-pair auth")
            sys.exit(1)
        from cryptography.hazmat.backends import default_backend
        from cryptography.hazmat.primitives import serialization
        with open(key_path, "rb") as f:
            p_key = serialization.load_pem_private_key(f.read(), password=None, backend=default_backend())
        conn_params["private_key"] = p_key.private_bytes(
            encoding=serialization.Encoding.DER,
            format=serialization.PrivateFormat.PKCS8,
            encryption_algorithm=serialization.NoEncryption(),
        )
    else:
        conn_params["password"] = os.environ.get("SNOWFLAKE_PASSWORD", "")

    return snowflake.connector.connect(**conn_params)


# ---------------------------------------------------------------------------
# Deploy — Semantic Views
# ---------------------------------------------------------------------------

def deploy_semantic_view(conn, yaml_path, database, schema, dry_run=False):
    """Deploy a semantic view from YAML via SYSTEM$CREATE_SEMANTIC_VIEW_FROM_YAML."""
    with open(yaml_path, "r") as f:
        yaml_content = f.read()

    yaml_content = yaml_content.replace("__DATABASE__", database)
    view_name = os.path.basename(yaml_path).replace(".yaml", "")
    full_schema = f"{database}.{schema}"

    # Phase 1: Validate YAML (verify_only=TRUE)
    validate_sql = f"CALL SYSTEM$CREATE_SEMANTIC_VIEW_FROM_YAML('{full_schema}', $${yaml_content}$$, TRUE)"
    deploy_sql = f"CALL SYSTEM$CREATE_SEMANTIC_VIEW_FROM_YAML('{full_schema}', $${yaml_content}$$)"

    if dry_run:
        log.info("[VIEW]  %s.%s  (dry-run)", full_schema, view_name)
        print(deploy_sql)
        print()
        return

    log.info("[VIEW]  Validating %s.%s", full_schema, view_name)
    try:
        with conn.cursor() as cur:
            cur.execute(validate_sql)
    except Exception as e:
        log.error("[VIEW]  Validation failed for %s: %s", view_name, e)
        raise

    log.info("[VIEW]  Deploying %s.%s", full_schema, view_name)
    with conn.cursor() as cur:
        cur.execute(deploy_sql)
    log.info("[VIEW]  Done")


# ---------------------------------------------------------------------------
# Deploy — Agents (idempotent: ALTER when exists, CREATE when new)
# ---------------------------------------------------------------------------

def _build_agent_spec(agent_config, database, schema, env_code, proj_code):
    """Build agent JSON spec and metadata from YAML config."""
    agent_name = agent_config["name"]
    full_agent = f"{database}.{schema}.{agent_name}"

    display_name = (
        agent_config.get("display_name", agent_name)
        .replace("${ENV_CODE}", env_code)
        .replace("${PROJ_CODE}", proj_code)
    )
    description = agent_config.get("description", "").replace("'", "''")
    warehouse = (
        agent_config.get("warehouse", f"{env_code}_{proj_code}_CORTEX_WH_XS")
        .replace("${ENV_CODE}", env_code)
        .replace("${PROJ_CODE}", proj_code)
    )
    timeout = agent_config.get("timeout_seconds", 60)
    token_limit = agent_config.get("token_limit", 16000)
    query_timeout = agent_config.get("query_timeout_seconds", 60)

    instructions_config = agent_config.get("instructions", {})
    instructions_obj = {}
    if instructions_config.get("orchestration"):
        instructions_obj["orchestration"] = instructions_config["orchestration"].strip()
    if instructions_config.get("response"):
        instructions_obj["response"] = instructions_config["response"].strip()

    sample_questions = agent_config.get("sample_questions", [])
    if sample_questions:
        instructions_obj["sample_questions"] = [{"question": q} for q in sample_questions]

    semantic_views = agent_config.get("semantic_views", [])
    tools = []
    tool_resources = {}
    for view in semantic_views:
        tools.append({
            "tool_spec": {
                "type": "cortex_analyst_text_to_sql",
                "name": view,
                "description": f"Analyst for {view}",
            }
        })
        tool_resources[view] = {
            "semantic_view": f"{database}.{schema}.{view}",
            "execution_environment": {
                "type": "warehouse",
                "warehouse": warehouse,
                "query_timeout_seconds": query_timeout,
            },
        }

    spec = {
        "orchestration": {"budget": {"seconds": timeout, "tokens": token_limit}},
        "instructions": instructions_obj,
        "tools": tools,
        "tool_resources": tool_resources,
    }

    grant_roles = []
    for role in agent_config.get("grant_to_roles", []):
        grant_roles.append(
            role.replace("${ENV_CODE}", env_code).replace("${PROJ_CODE}", proj_code)
        )

    return full_agent, display_name, description, spec, grant_roles


def deploy_agent(conn, yaml_path, env_code, proj_code, database, schema, dry_run=False):
    """Deploy an agent from YAML — idempotent via DESCRIBE → compare → ALTER/CREATE."""
    with open(yaml_path, "r") as f:
        agent_config = yaml.safe_load(f)

    full_agent, display_name, description, spec, grant_roles = _build_agent_spec(
        agent_config, database, schema, env_code, proj_code
    )

    spec_json = json.dumps(spec, sort_keys=True)
    profile_json = json.dumps({"display_name": display_name})

    create_sql = (
        f"CREATE AGENT {full_agent}\n"
        f"    WITH PROFILE = '{profile_json}'\n"
        f"    , COMMENT = '{description}'\n"
        f"    FROM SPECIFICATION $${spec_json}$$"
    )
    alter_spec_sql = (
        f"ALTER AGENT {full_agent}\n"
        f"    MODIFY LIVE VERSION SET SPECIFICATION = $${spec_json}$$"
    )
    alter_profile_sql = (
        f"ALTER AGENT {full_agent} SET\n"
        f"    PROFILE = '{profile_json}'\n"
        f"    , COMMENT = '{description}'"
    )
    grant_sqls = [f'GRANT USAGE ON AGENT {full_agent} TO ROLE "{r}"' for r in grant_roles]

    if dry_run:
        log.info("[AGENT] %s  (dry-run)", full_agent)
        print(create_sql + ";")
        for gs in grant_sqls:
            print(gs + ";")
        print()
        return

    # Check if agent exists
    agent_exists = False
    spec_changed = True
    try:
        with conn.cursor() as cur:
            cur.execute(f"SHOW AGENTS LIKE '{agent_config['name']}' IN SCHEMA {database}.{schema}")
            if cur.fetchone():
                agent_exists = True
    except Exception:
        pass

    if agent_exists:
        # Compare current spec with new spec
        try:
            with conn.cursor() as cur:
                cur.execute(f"DESCRIBE AGENT {full_agent}")
                desc = cur.fetchone()
            current_spec = json.loads(desc[6]) if desc[6] else {}
            new_spec = json.loads(spec_json)
            if json.dumps(current_spec, sort_keys=True) == json.dumps(new_spec, sort_keys=True):
                spec_changed = False
        except Exception:
            pass

    if not agent_exists:
        log.info("[AGENT] Creating %s", full_agent)
        with conn.cursor() as cur:
            cur.execute(create_sql)
        log.info("[AGENT] Created")
    elif spec_changed:
        log.info("[AGENT] Updating %s (spec changed)", full_agent)
        with conn.cursor() as cur:
            cur.execute(alter_spec_sql)
        with conn.cursor() as cur:
            cur.execute(alter_profile_sql)
        log.info("[AGENT] Updated (ALTER — chat history preserved)")
    else:
        log.info("[AGENT] Skipping %s (no changes)", full_agent)

    # Grants (always run — idempotent)
    for gs in grant_sqls:
        with conn.cursor() as cur:
            cur.execute(gs)
        log.info("[AGENT] Granted: %s", gs.split("TO ROLE")[1].strip().strip('"'))


# ---------------------------------------------------------------------------
# Pull  (Snowflake → YAML)
# ---------------------------------------------------------------------------

def _re_param(value, env_code, proj_code, database):
    """Replace environment-specific values with placeholders."""
    if not isinstance(value, str):
        return value
    return (
        value
        .replace(database, "${ENV_CODE}_${PROJ_CODE}_DW_DB")
        .replace(env_code, "${ENV_CODE}")
        .replace(proj_code, "${PROJ_CODE}")
    )


def pull_semantic_views(conn, database, schema, output_dir, views_filter=None):
    with conn.cursor() as cur:
        cur.execute(f"SHOW SEMANTIC VIEWS IN SCHEMA {database}.{schema}")
        rows = cur.fetchall()

    pulled = 0
    for row in rows:
        view_name = row[1]
        if views_filter is not None and view_name.lower() not in views_filter:
            continue
        with conn.cursor() as cur:
            cur.execute(f"SELECT SYSTEM$READ_YAML_FROM_SEMANTIC_VIEW('{database}.{schema}.{view_name}')")
            yaml_content = cur.fetchone()[0]
        normalized = _normalize_semantic_view_yaml(yaml_content, database)
        out_path = os.path.join(output_dir, f"{view_name.lower()}.yaml")
        with open(out_path, "w") as f:
            f.write(normalized)
        log.info("[PULL]  Wrote semantic view: %s", out_path)
        pulled += 1
    return pulled


def pull_agents(conn, database, schema, output_dir, env_code, proj_code, agents_filter=None):
    with conn.cursor() as cur:
        cur.execute(f"SHOW AGENTS IN SCHEMA {database}.{schema}")
        rows = cur.fetchall()

    pulled = 0
    for row in rows:
        agent_name = row[1]
        if agents_filter is not None and agent_name.lower() not in agents_filter:
            continue
        with conn.cursor() as cur:
            cur.execute(f"DESCRIBE AGENT {database}.{schema}.{agent_name}")
            desc = cur.fetchone()

        comment = desc[4] or ""
        profile = json.loads(desc[5]) if desc[5] else {}
        spec = json.loads(desc[6]) if desc[6] else {}

        with conn.cursor() as cur:
            cur.execute(f"SHOW GRANTS ON AGENT {database}.{schema}.{agent_name}")
            grants = cur.fetchall()
        usage_roles = [_re_param(g[5], env_code, proj_code, database) for g in grants if g[1] == "USAGE"]

        budget = spec.get("orchestration", {}).get("budget", {})
        instructions = spec.get("instructions", {})
        tools = spec.get("tools", [])
        tool_resources = spec.get("tool_resources", {})
        semantic_views = [t["tool_spec"]["name"] for t in tools]

        warehouse, query_timeout = "", 60
        for _, res in tool_resources.items():
            env = res.get("execution_environment", {})
            warehouse = env.get("warehouse", "")
            query_timeout = env.get("query_timeout_seconds", 60)
            break

        agent_yaml = {"name": agent_name.lower()}
        agent_yaml["display_name"] = _re_param(profile.get("display_name", agent_name), env_code, proj_code, database)
        if comment:
            agent_yaml["description"] = comment
        if semantic_views:
            agent_yaml["semantic_views"] = semantic_views
        agent_yaml["warehouse"] = _re_param(warehouse, env_code, proj_code, database)
        agent_yaml["timeout_seconds"] = budget.get("seconds", 60)
        agent_yaml["token_limit"] = budget.get("tokens", 16000)
        agent_yaml["query_timeout_seconds"] = query_timeout
        if usage_roles:
            agent_yaml["grant_to_roles"] = usage_roles

        instr = {}
        if instructions.get("orchestration"):
            instr["orchestration"] = instructions["orchestration"]
        if instructions.get("response"):
            instr["response"] = instructions["response"]
        if instr:
            agent_yaml["instructions"] = instr
        sq = instructions.get("sample_questions", [])
        if sq:
            agent_yaml["sample_questions"] = [q["question"] for q in sq]

        out_path = os.path.join(output_dir, f"{agent_name.lower()}.yaml")
        with open(out_path, "w") as f:
            yaml.dump(agent_yaml, f, Dumper=_CleanDumper, default_flow_style=False, sort_keys=False, allow_unicode=True, width=120)
        log.info("[PULL]  Wrote agent: %s", out_path)
        pulled += 1
    return pulled


# ---------------------------------------------------------------------------
# Status  (local YAML vs deployed — with content drift detection)
# ---------------------------------------------------------------------------

def _get_deployed_view_yaml(conn, database, schema, view_name):
    """Read and normalize deployed semantic view YAML for comparison."""
    try:
        with conn.cursor() as cur:
            cur.execute(f"SELECT SYSTEM$READ_YAML_FROM_SEMANTIC_VIEW('{database}.{schema}.{view_name}')")
            return _normalize_semantic_view_yaml(cur.fetchone()[0], database)
    except Exception:
        return None


def _get_local_view_yaml(yaml_path, database):
    """Read and normalize local semantic view YAML for comparison."""
    with open(yaml_path, "r") as f:
        content = f.read()
    # Normalize the same way we normalize pulled YAML
    resolved = content.replace("__DATABASE__", database)
    return _normalize_semantic_view_yaml(resolved, database)


def show_status(conn, database, schema, views_dir, agents_dir, views_filter=None, agents_filter=None):
    """Compare local YAML with deployed Snowflake objects — detects content drift."""

    local_view_files = {
        os.path.basename(f).replace(".yaml", "").upper(): f
        for f in glob.glob(os.path.join(views_dir, "*.yaml"))
    }
    local_agent_files = {
        os.path.basename(f).replace(".yaml", "").upper(): f
        for f in glob.glob(os.path.join(agents_dir, "*.yaml"))
    }

    with conn.cursor() as cur:
        cur.execute(f"SHOW SEMANTIC VIEWS IN SCHEMA {database}.{schema}")
        deployed_views = {row[1].upper() for row in cur.fetchall()}
    with conn.cursor() as cur:
        cur.execute(f"SHOW AGENTS IN SCHEMA {database}.{schema}")
        deployed_agents = {row[1].upper() for row in cur.fetchall()}

    if views_filter is not None:
        vf = {v.upper() for v in views_filter}
        local_view_files = {k: v for k, v in local_view_files.items() if k in vf}
        deployed_views = deployed_views & vf
    if agents_filter is not None:
        af = {a.upper() for a in agents_filter}
        local_agent_files = {k: v for k, v in local_agent_files.items() if k in af}
        deployed_agents = deployed_agents & af

    print(f"\n{'='*60}")
    print(f"  Status: {database}.{schema}")
    print(f"{'='*60}")

    # Semantic views — with content comparison
    print(f"\n  Semantic Views:")
    print(f"  {'Name':<40} {'Status':<20}")
    print(f"  {'-'*40} {'-'*20}")
    all_views = sorted(set(local_view_files.keys()) | deployed_views)
    if not all_views:
        print(f"  (none)")
    for v in all_views:
        in_local = v in local_view_files
        in_deployed = v in deployed_views
        if in_local and in_deployed:
            local_yaml = _get_local_view_yaml(local_view_files[v], database)
            deployed_yaml = _get_deployed_view_yaml(conn, database, schema, v)
            status = "SYNCED" if local_yaml == deployed_yaml else "DRIFTED"
        elif in_local:
            status = "LOCAL ONLY"
        else:
            status = "DEPLOYED ONLY"
        print(f"  {v:<40} {status:<20}")

    # Agents — name check only (spec comparison is expensive)
    print(f"\n  Agents:")
    print(f"  {'Name':<40} {'Status':<20}")
    print(f"  {'-'*40} {'-'*20}")
    all_agents = sorted(set(local_agent_files.keys()) | deployed_agents)
    if not all_agents:
        print(f"  (none)")
    for a in all_agents:
        in_local = a in local_agent_files
        in_deployed = a in deployed_agents
        if in_local and in_deployed:
            status = "SYNCED"
        elif in_local:
            status = "LOCAL ONLY"
        else:
            status = "DEPLOYED ONLY"
        print(f"  {a:<40} {status:<20}")

    print()


# ---------------------------------------------------------------------------
# Main
# ---------------------------------------------------------------------------

def main():
    parser = argparse.ArgumentParser(
        description="Deploy and manage Cortex Analyst semantic views and agents from YAML.",
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
examples:
  python deploy.py                            Deploy all
  python deploy.py --dry-run                  Print SQL without executing
  python deploy.py --pull                     Export Snowflake → YAML
  python deploy.py --status                   Compare local vs deployed
  python deploy.py --views v1 v2              Deploy specific views
  python deploy.py --pull --agents a1         Pull specific agent
        """,
    )
    parser.add_argument("--views", nargs="*", default=None, help="Filter to specific semantic views")
    parser.add_argument("--agents", nargs="*", default=None, help="Filter to specific agents")
    parser.add_argument("--schema", default="SEMANTIC", help="Target schema (default: SEMANTIC)")
    parser.add_argument("--dry-run", action="store_true", help="Print SQL without executing")
    parser.add_argument("--pull", action="store_true", help="Export Snowflake definitions to YAML")
    parser.add_argument("--status", action="store_true", help="Compare local YAML vs deployed objects")
    args = parser.parse_args()

    env_code, proj_code, database = get_env()
    schema = args.schema
    script_dir = os.path.dirname(os.path.abspath(__file__))
    views_dir = os.path.join(script_dir, "..", "semantic_views")
    agents_dir = os.path.join(script_dir, "..", "agents")

    views_filter = [v.lower() for v in args.views] if args.views is not None else None
    agents_filter = [a.lower() for a in args.agents] if args.agents is not None else None

    log.info("DATABASE: %s  SCHEMA: %s  MODE: %s",
             database, schema,
             "pull" if args.pull else "status" if args.status else "dry-run" if args.dry_run else "deploy")

    if args.status:
        conn = get_connection()
        show_status(conn, database, schema, views_dir, agents_dir, views_filter, agents_filter)
        conn.close()
        return

    if args.pull:
        conn = get_connection()
        os.makedirs(views_dir, exist_ok=True)
        os.makedirs(agents_dir, exist_ok=True)
        v = pull_semantic_views(conn, database, schema, views_dir, views_filter)
        a = pull_agents(conn, database, schema, agents_dir, env_code, proj_code, agents_filter)
        conn.close()
        log.info("Pulled %d view(s), %d agent(s)", v, a)
        log.info("Review changes: git diff")
        return

    conn = None if args.dry_run else get_connection()

    yaml_files = sorted(glob.glob(os.path.join(views_dir, "*.yaml")))
    deployed_views = 0
    for yaml_path in yaml_files:
        name = os.path.basename(yaml_path).replace(".yaml", "")
        if views_filter is not None and name.lower() not in views_filter:
            continue
        deploy_semantic_view(conn, yaml_path, database, schema, dry_run=args.dry_run)
        deployed_views += 1

    agent_files = sorted(glob.glob(os.path.join(agents_dir, "*.yaml")))
    deployed_agents = 0
    for yaml_path in agent_files:
        name = os.path.basename(yaml_path).replace(".yaml", "")
        if agents_filter is not None and name.lower() not in agents_filter:
            continue
        deploy_agent(conn, yaml_path, env_code, proj_code, database, schema, dry_run=args.dry_run)
        deployed_agents += 1

    if conn:
        conn.close()

    log.info("Complete: %d view(s), %d agent(s) %s",
             deployed_views, deployed_agents,
             "printed" if args.dry_run else "deployed")


if __name__ == "__main__":
    try:
        main()
    except Exception as e:
        log.error("FAILED: %s", e)
        sys.exit(1)
