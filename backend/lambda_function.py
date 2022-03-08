import boto3
import json
import os

def lambda_handler(event,context):

    dynamodb = boto3.resource('dynamodb')
    dynamodbTable = os.environ['ddbname']
    dynamodbResponse = dynamodbTable.update_item(
        Key = {
            "id": "visitorcount"
        },
        UpdateExpression='SET id = :inc',
        ExpressionAttributeValues={
            ':inc': 1
        },
        ReturnValues= "UPDATED_NEW"
    )

    responseBody = json.dumps({"visitorcount": int(float(dynamodbResponse["Attributes"]["id"]))})

    response = {
        'Status-code': 200,
        'body': responseBody,
        'headers': {
            'content-type': 'application/json',
            'Access-Control-Allow-Origin': '*'
        }
    }

    return response
