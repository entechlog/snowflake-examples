- [Overview](#overview)
  - [Instructions](#instructions)
  - [Clean Resources](#clean-resources)
  - [Reference](#reference)

# Overview
Demo project to load data from s3 bucket to Snowflake using dbt, mage ai

## Instructions

- Start the container by running
  
```bash
docker-compose up --remove-orphans -d --build
```

- You can access the Mage UI by visiting http://localhost:6789, and the Mage Terminal is accessible at http://localhost:6789/terminal.

- Start and ssh into the dev-tools container
  
  ```bash
  docker exec -it developer-tools /bin/bash
  ```

- Create the dbt models by running
  ```
  dbt run --select tag:source
  dbt run --select tag:dw
  dbt run-operation delete_orphaned_tables 
--args "{databases_list: ['TST_ENTECHLOG_PREP_DB', 'TST_ENTECHLOG_DW_DB'], dry_run: False}"
  ```



## Clean Resources

```bash
docker-compose down --volumes 
```

## Reference

- http://mamykin.com/posts/fast-data-load-snowflake-dbt/
- https://github.com/braze-inc/braze-examples/blob/main/data-ingestion/community-examples/braze_user_snowflake_share.sql