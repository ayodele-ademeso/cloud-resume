#Create API-GATEWAY module
resource "aws_api_gateway_rest_api" "MyAPI" {
    name = "CountAPI"
    description = "The REST API to trigger lambda"  
}

resource "aws_api_gateway_resource" "APIresource" {
    parent_id = aws_api_gateway_rest_api.MyAPI.root_resource_id
    path_part = "count"
    rest_api_id = aws_api_gateway_rest_api.MyAPI.id
}

resource "aws_api_gateway_method" "APIMethod" {
    authorization = "NONE"
    http_method = "GET"
    resource_id = aws_api_gateway_resource.APIresource.id
    rest_api_id = aws_api_gateway_rest_api.MyAPI.id
}

resource "aws_api_gateway_integration" "IntegrationPoint" {
    http_method = aws_api_gateway_method.APIMethod.http_method
    resource_id = aws_api_gateway_resource.APIresource.id
    rest_api_id = aws_api_gateway_rest_api.MyAPI.id
    type = "AWS_PROXY"
}

resource "aws_api_gateway_deployment" "Deployment" {
    rest_api_id = aws_api_gateway_rest_api.MyAPI.id

    triggers = {
        redeployment = sha1(jsonencode([
            aws_api_gateway_resource.APIresource.id,
            aws_api_gateway_method.APIMethod.id,
            aws_api_gateway_integration.IntegrationPoint.id,
        ]))
    }

    lifecycle {
      create_before_destroy = true
    }
}

resource "aws_api_gateway_stage" "stage" {
    deployment_id = aws_api_gateway_deployment.Deployment.id
    rest_api_id = aws_api_gateway_rest_api.MyAPI.id
    stage_name = "dev"
}