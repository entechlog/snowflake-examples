USE SCHEMA <schema-name>;

-- demo
SELECT demo('100') AS demo_result;

-- get_weather
select 'kansas' AS location, get_weather(location):temperature::varchar as current_temperature
UNION ALL
select 'london' AS location, get_weather(location):temperature::varchar as current_temperature
UNION ALL
select 'chennai' AS location, get_weather(location):temperature::varchar as current_temperature;

-- get_weather_open
WITH source
AS (
	SELECT get_weather_open('kansas') AS open_weather_data
	UNION ALL
	SELECT get_weather_open('trivandrum') AS open_weather_data
	)

SELECT
open_weather_data: dt AS DATE,
open_weather_data: name::VARCHAR AS location,
open_weather_data:
main: TEMP AS TEMP
FROM source;
