resource "aws_apigatewayv2_api" "api" {
  name                         = "overridden by openapi title"
  protocol_type                = "HTTP"
  disable_execute_api_endpoint = true
  body = templatefile("${var.openapi_file}", {
    api_proxy = var.api_proxy
    vpc_link_id = var.vpc_link_id
    service_discovery_arns = var.service_discovery_arns
  })
}

resource "aws_apigatewayv2_deployment" "api_deployment" {
  api_id      = aws_apigatewayv2_api.api.id
  description = "Deployment at ${timestamp()}"
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_cloudwatch_log_group" "api_gw_log_group" {
  name              = "/aws/api-gateway/${aws_apigatewayv2_api.api.id}/${var.api_stage_name}/logs"
  retention_in_days = var.api_logs_retention_days
}

resource "aws_apigatewayv2_stage" "dev_stage" {
  api_id        = aws_apigatewayv2_api.api.id
  deployment_id = aws_apigatewayv2_deployment.api_deployment.id
  name          = var.api_stage_name
  access_log_settings {
    destination_arn = aws_cloudwatch_log_group.api_gw_log_group.arn
    format = replace(replace(
      <<EOF
        {
          "requestTime": "$context.requestTime",
          "requestId": "$context.requestId",
          "httpMethod": "$context.httpMethod",
          "path": "$context.path",
          "routeKey": "$context.routeKey",
          "status": $context.status,
          "responseLatency": $context.responseLatency,
          "responseLength": $context.responseLength,
          "integrationRequestId": "$context.integration.requestId",
          "functionResponseStatus": "$context.integration.status",
          "integrationLatency": "$context.integration.latency",
          "integrationServiceStatus": "$context.integration.integrationStatus",
          "authorizeResultStatus": "$context.authorizer.status",
          "authorizerRequestId": "$context.authorizer.requestId",
          "ip": "$context.identity.sourceIp",
          "userAgent": "$context.identity.userAgent",
          "principalId": "$context.authorizer.principalId",
          "cognitoUser": "$context.identity.cognitoIdentityId",
          "iamUser": "$context.identity.user"
        }
      EOF
    , "\n", ""), "\r", "")
  }
}
