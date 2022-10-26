import json

def lambda_handler(event, context):

    # 200 is the HTTP status code for "ok".
    status_code = 200

    # The return value will contain an array of arrays (one inner array per input row).
    array_of_rows_to_return = [ ]

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

            # Read the first input parameter's value. For example, this can be a
            # numeric value or a string, or it can be a compound value such as
            # a JSON structure.
            input_value_1 = row[1]

            # Compose the output based on the input. This simple example
            # merely echoes the input by collecting the values into an array that
            # will be treated as a single VARIANT value.
            output_value = ["Echoing inputs:", input_value_1]

            # Put the returned row number and the returned value into an array.
            row_to_return = [row_number, output_value]

            # ... and add that array to the main array.
            array_of_rows_to_return.append(row_to_return)

        json_compatible_string_to_return = json.dumps({"data" : array_of_rows_to_return})

    except Exception as err:
        # 400 implies some type of error.
        status_code = 400
        # Tell caller what this function could not handle.
        json_compatible_string_to_return = event_body

    # Return the return value and HTTP status code.
    return {
        'statusCode': status_code,
        'body': json_compatible_string_to_return
    }