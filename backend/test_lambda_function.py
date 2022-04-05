import boto3
import os
import json
import unittest
from contextlib import contextmanager
from moto import mock_dynamodb2
import lambda_function
from unittest import mock

TABLE = 'testdb'

class LambdaTest(unittest.TestCase):
    """Tests for lambda function"""

    @contextmanager
    def do_test_setup():
        with mock_dynamodb2():
            set_up_dynamodb()
            yield


    def set_up_dynamodb():
        client = boto3.client('dynamodb', region_name='us-east-1')
        client.create_table(
            AttributeDefinitions=[
                {
                    'AttributeName': 'visitorcount',
                    'AttributeType': 'S'
                },
            ],
            KeySchema=[
                {
                    'AttributeName': 'visitorcount',
                    'KeyType': 'HASH'
                }
            ],
            TableName=TABLE,
            ProvisionedThroughput={
                'ReadCapacityUnits': 1,
                'WriteCapacityUnits': 1
            }
        )


    @mock.patch.dict(os.environ, {"databaseName": TABLE})
    def test_handler(*args):
        #with do_test_setup():
            # Run call with an event describing the file:
            response = lambda_function.lambda_handler(None, None)

            # Check that it exists in `processed/`
            assert response['statusCode'] == 200
            assert response['body'] == json.dumps({"count": 1})

            response = app.lambda_handler(None, None)

            assert response['statusCode'] == 200
            assert response['body'] == json.dumps({"count": 2})

if __name__ == '__main__':
    unittest.main()