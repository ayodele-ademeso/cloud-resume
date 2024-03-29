import boto3
import json
import os
import botocore.exceptions

def lambda_handler(event,context):

    dynamodb = boto3.resource('dynamodb')
    dynamodbTable = os.environ['DB_NAME']
    table = dynamodb.Table(dynamodbTable)
    response = None
    responseBody = {}  # Initialize with an empty dictionary

    #update value of item atrribute in table by 1 or add attribute if it does not exist
    try:
        dynamodbResponse = table.update_item(
            Key = {
                "visitorcount": "count"
            },
            #Using 'ADD' to increment value of the attribute 'count' by 1
            UpdateExpression='ADD counters :inc', #counter is a reserved keyword so I went with counters.
            ExpressionAttributeValues={
                ':inc': 1
            },
            ReturnValues= "UPDATED_NEW"
        )
    except botocore.exceptions.ClientError as e:
        print(e)

    else:
        responseBody = json.dumps({"count": int(float(dynamodbResponse["Attributes"]["counters"]))})

    return responseBody