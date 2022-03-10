import boto3
import json
import os

def lambda_handler(event,context):

    dynamodb = boto3.resource('dynamodb')
    dynamodbTable = os.environ['ddbname']
    table = dynamodb.Table(dynamodbTable)

    #update item in table by 1 or add item if it does not exist
    dynamodbResponse = table.update_item(
        Key = {
            "visitorcount": "count"
        },
        UpdateExpression='SET counter = counter + :inc',
        ExpressionAttributeValues={
            ':inc': 1
        },
        ReturnValues= "UPDATED_NEW"
    )

    responseBody = json.dumps({"count": int(float(dynamodbResponse["Attributes"]["counter"]))})

    response = {
        'Status-code': 200,
        'body': responseBody,
        'headers': {
            'content-type': 'application/json',
            'Access-Control-Allow-Origin': '*'
        }
    }

    return response
