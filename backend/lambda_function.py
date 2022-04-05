import boto3
import json
import os

def lambda_handler(event,context):

    dynamodb = boto3.resource('dynamodb')
    dynamodbTable = os.environ['ddbname']
    table = dynamodb.Table(dynamodbTable)

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
    except ClientError as e:
        print(e)
    else:
        responseBody = json.dumps({"count": int(float(dynamodbResponse["Attributes"]["counters"]))})

        response = {
            'Status-code': 200,
            'body': responseBody,
            'headers': {
                'content-type': 'application/json',
                'Access-Control-Allow-Origin': '*'
            }
        }

    return response
