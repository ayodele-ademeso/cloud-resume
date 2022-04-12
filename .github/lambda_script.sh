#!/bin/bash

zip lambda_function.zip ../backend/lambda_function.py
aws lambda update-function-code \
    --function-name  lambda_function2 \
    --zip-file fileb://lambda_function.zip

echo “function updated successfully”