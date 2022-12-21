resource "aws_api_gateway_rest_api" "lambda" {
  name                         = "${var.name}-api"
  description                  = "API for AWS Lambda"
  disable_execute_api_endpoint = true
  endpoint_configuration {
    types = ["REGIONAL"]
  }
}

resource "aws_api_gateway_method" "lambda" {
  authorization = "NONE"
  http_method   = "GET"
  resource_id   = aws_api_gateway_rest_api.lambda.root_resource_id
  rest_api_id   = aws_api_gateway_rest_api.lambda.id
}

resource "aws_api_gateway_integration" "lambda" {
  http_method             = aws_api_gateway_method.lambda.http_method
  resource_id             = aws_api_gateway_method.lambda.resource_id
  rest_api_id             = aws_api_gateway_method.lambda.rest_api_id
  type                    = "AWS"
  integration_http_method = "POST"
  uri                     = aws_lambda_function.this.arn
}

resource "aws_api_gateway_method_response" "lambda" {
  http_method     = aws_api_gateway_method.lambda.http_method
  resource_id     = aws_api_gateway_rest_api.lambda.root_resource_id
  rest_api_id     = aws_api_gateway_rest_api.lambda.id
  status_code     = "200"
  response_models = {
    "application/json" = "Empty"
  }
}

resource "aws_api_gateway_integration_response" "lambda" {
  http_method = aws_api_gateway_method.lambda.http_method
  resource_id = aws_api_gateway_rest_api.lambda.root_resource_id
  rest_api_id = aws_api_gateway_rest_api.lambda.id
  status_code = aws_api_gateway_method_response.lambda.status_code
  depends_on  = [aws_api_gateway_integration.lambda]
}

resource "aws_api_gateway_deployment" "lambda" {
  rest_api_id = aws_api_gateway_rest_api.lambda.id

  triggers = {
    redeployment = sha1(jsonencode(
      [
        aws_api_gateway_method.lambda.id,
        aws_api_gateway_integration.lambda.id,
        aws_api_gateway_method_response.lambda,
        aws_api_gateway_integration_response.lambda,
      ]
    ))
  }
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_api_gateway_stage" "lambda" {
  deployment_id = aws_api_gateway_deployment.lambda.id
  rest_api_id   = aws_api_gateway_rest_api.lambda.id
  stage_name    = "run"
}

resource "aws_api_gateway_base_path_mapping" "lambda" {
  api_id      = aws_api_gateway_rest_api.lambda.id
  domain_name = aws_api_gateway_domain_name.this.domain_name
  stage_name  = aws_api_gateway_deployment.lambda.stage_name
  base_path   = null
}

resource "aws_lambda_permission" "lambda" {
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.this.function_name
  principal     = "apigateway.amazonaws.com"
  statement_id  = "AllowExecutionFromAPIGateway"
  source_arn    = "${aws_api_gateway_rest_api.lambda.execution_arn}/"
}