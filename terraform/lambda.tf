resource "aws_lambda_function" "lambda_function" {
  function_name    = "process-dynamodb-records"
  filename         = data.archive_file.lambda_zip_file.output_path
  source_code_hash = data.archive_file.lambda_zip_file.output_base64sha256
  handler          = "index.handler"
  role             =  "arn:aws:iam::123456789012:role/lambda-dynamodb-role"
  runtime          = "nodejs12.x"
}

data "archive_file" "lambda_zip_file" {
  output_path = "${path.module}/lambda_zip/lambda.zip"
  source_dir  = "${path.module}/../lambda-src"
  excludes    = []
  type        = "zip"
}

resource "aws_lambda_event_source_mapping" "example" {
  event_source_arn  = aws_dynamodb_table.dynamodb_table.stream_arn
  function_name     = aws_lambda_function.lambda_function.arn
  starting_position = "LATEST"

  filter_criteria {
    filter {
      pattern = jsonencode({
        "userIdentity" : {
          "type" : ["Service"],
          "principalId" : ["dynamodb.amazonaws.com"]
        }
      })
    }
  }
}
