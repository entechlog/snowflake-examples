import requests
import json


def lambda_handler(event, context):

    # 200 is the HTTP status code for "ok".
    status_code = 200

    # The return value will contain an array of arrays (one inner array per input row).
    array_of_rows_to_return = []

    # From the input parameter named "event", get the body, which contains
    # the input rows.
    event_body = event["body"]

    try:
        # Convert the input from a JSON string into a JSON object.
        payload = json.loads(event_body)

        # This is basically an array of arrays. The inner array contains the
        # row number, and a value for each parameter passed to the function.
        rows = payload["data"]

        # For each input row in the JSON object...
        for row in rows:
            # Read the input row number (the output row number will be the same).
            row_number = row[0]

            # Read the first input parameter's value.
            location_code = row[1]

            # api-endpoint
            URL = 'https://weatherdbi.herokuapp.com/data/weather/' + location_code

            # defining a params dict for the parameters to be sent to the API
            PARAMS = {}

            # sending get request and saving the response as response object
            try:
                response = requests.get(url=URL, params=PARAMS, timeout=3)
                response.raise_for_status()
                response_json = json.loads(response.text)
            except requests.exceptions.HTTPError as errh:
                print("Http Error: ", errh)
            except requests.exceptions.ConnectionError as errc:
                print("Error Connecting: ", errc)
            except requests.exceptions.Timeout as errt:
                print("Timeout Error: ", errt)
            except requests.exceptions.RequestException as err:
                print("Something Else: ", err)

            response_parsed = response_json['currentConditions']
            print("response_parsed : ", response_parsed)

            # Compose the output
            output_value = response_parsed

            # Put the returned row number and the returned value into an array.
            row_to_return = [row_number, output_value]

            # ... and add that array to the main array.
            array_of_rows_to_return.append(row_to_return)

        json_compatible_string_to_return = json.dumps(
            {"data": array_of_rows_to_return})

    except Exception as err:
        print("Input Error ", err)
        # 400 implies some type of error.
        status_code = 400
        # Tell caller what this function could not handle.
        json_compatible_string_to_return = event_body

    # Return the return value and HTTP status code.
    return {
        'statusCode': status_code,
        'body': json_compatible_string_to_return
    }
