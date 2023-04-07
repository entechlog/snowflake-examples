USE DATABASE <database-name>;
USE SCHEMA <schema-name>;

-- validate pipes
SHOW PIPES;
DESC PIPE <pipe-name>;
SELECT SYSTEM$PIPE_STATUS('<database-name>.<schema-name>.<pipe-name>');

-- validate copy history
SELECT *
FROM TABLE(information_schema.copy_history(TABLE_NAME=>'<database-name>.<schema-name>.<table-name>', START_TIME=> DATEADD(hours, -1, CURRENT_TIMESTAMP())));

-- validate data in final table
SELECT * FROM <database-name>.<schema-name>.<table-name>;
