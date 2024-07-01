import requests
import json
import botocore
import botocore.session
from aws_secretsmanager_caching import SecretCache, SecretCacheConfig

def mask_ip(ip):
    """Mask parts of the IP address for privacy."""
    parts = ip.split('.')
    if len(parts) == 4:
        return f"{parts[0]}.{parts[1]}.***.{parts[3]}"
    return ip  # Return the original IP if it's not a valid format

def lambda_handler(event, context):
    """Main Lambda handler function."""
    
    # 200 is the HTTP status code for "ok".
    status_code = 200

    # The return value will contain an array of arrays (one inner array per input row).
    array_of_rows_to_return = []

    # From the input parameter named "event", get the body, which contains the input rows.
    event_body = event.get("body", "{}")

    try:
        # Convert the input from a JSON string into a JSON object.
        payload = json.loads(event_body)

        # This is basically an array of arrays. The inner array contains the row number, and a value for each parameter passed to the function.
        rows = payload.get("data", [])

        # For each input row in the JSON object...
        for row in rows:

            # Initialize response
            response_json = {}

            # Read the input row number (the output row number will be the same).
            row_number = row[0]

            # Read the first input parameter's value.
            ip = row[1]

            # Mask the IP address for logging
            masked_ip = mask_ip(ip)

            # API endpoint
            URL = "https://api.ipgeolocation.io/ipgeo"
            
            # Set up Secrets Manager
            client = botocore.session.get_session().create_client('secretsmanager')
            cache_config = SecretCacheConfig()
            cache = SecretCache(config=cache_config, client=client)
            
            secret_name = '/lambda/external_function/ipgeolocation_api_key'
            print(f"Attempting to read secret: {secret_name}")
            secret = cache.get_secret_string(secret_name)

            IPGEOLOCATION_API_KEY = json.loads(secret)['ipgeolocation_api_key']

            # Prepare inputs for geolocation API call
            PARAMS = {'apiKey': IPGEOLOCATION_API_KEY, 'ip': ip}

            # Log that the request is being made, but do not log the actual parameters
            print(f"Making request to {URL} for IP: {masked_ip}")

            # Sending get request and saving the response as response object
            try:
                response = requests.get(url=URL, params=PARAMS, timeout=3)
                response.raise_for_status()
                response_json = response.json()
                print(f"Request successful for IP: {masked_ip}")
            except requests.exceptions.HTTPError as errh:
                print(f"HTTP Error for IP {masked_ip}: {errh}")
                response_json = {"error": "HTTP Error"}
            except requests.exceptions.ConnectionError as errc:
                print(f"Connection Error for IP {masked_ip}: {errc}")
                response_json = {"error": "Connection Error"}
            except requests.exceptions.Timeout as errt:
                print(f"Timeout Error for IP {masked_ip}: {errt}")
                response_json = {"error": "Timeout Error"}
            except requests.exceptions.RequestException as err:
                print(f"Request Exception for IP {masked_ip}: {err}")
                response_json = {"error": "Request Exception"}

            # Parse the response
            response_parsed = response_json

            # Log the parsed response (if necessary, you can mask or omit sensitive parts)
            # print(f"Parsed response for IP {masked_ip}: {response_parsed}")

            # Compose the output
            output_value = response_parsed

            # Put the returned row number and the returned value into an array.
            row_to_return = [row_number, output_value]

            # ... and add that array to the main array.
            array_of_rows_to_return.append(row_to_return)

        json_compatible_string_to_return = json.dumps({"data": array_of_rows_to_return})

    except Exception as err:
        print(f"Input Error: {err}")
        # 400 implies some type of error.
        status_code = 400
        # Tell caller what this function could not handle.
        json_compatible_string_to_return = json.dumps({"error": str(err)})

    # Return the return value and HTTP status code.
    return {
        'statusCode': status_code,
        'body': json_compatible_string_to_return
    }
