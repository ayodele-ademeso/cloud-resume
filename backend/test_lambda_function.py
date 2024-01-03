import unittest
from unittest import mock
import boto3
import botocore.exceptions
from lambda_function import lambda_handler


class TestLambdaHandler(unittest.TestCase):

    @mock.patch('lambda_function.boto3')
    def test_lambda_handler_success(self, mock_boto3):
        mock_table = mock.MagicMock()
        mock_table.update_item.return_value = {
            'Attributes': {'counters': 10}
        }
        mock_table.return_value = mock_table
        mock_resource = mock.MagicMock()
        mock_resource.Table.return_value = mock_table
        mock_boto3.resource.return_value = mock_resource

        event = {}
        context = {}

        response = lambda_handler(event, context)

        # self.assertEqual(response['Status-code'], 200)
        # self.assertEqual(response['headers']['content-type'], 'application/json')
        # self.assertEqual(response['headers']['Access-Control-Allow-Origin'], '*')
        self.assertEqual(response, '{"count": 10}')

    @mock.patch('lambda_function.boto3')
    def test_lambda_handler_exception(self, mock_boto3):
        mock_table = mock.MagicMock()
        mock_table.update_item.side_effect = botocore.exceptions.ClientError(
            {'Error': {'Code': 'SomeErrorCode'}},
            'OperationName'
        )
        mock_table.return_value = mock_table
        mock_resource = mock.MagicMock()
        mock_resource.Table.return_value = mock_table
        mock_boto3.resource.return_value = mock_resource

        event = {}
        context = {}

        response = lambda_handler(event, context)

        self.assertEqual(response, {})

if __name__ == '__main__':
    unittest.main()