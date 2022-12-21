resource "aws_api_gateway_domain_name" "this" {
  domain_name = aws_api_gateway_stage.lambda.invoke_url
}