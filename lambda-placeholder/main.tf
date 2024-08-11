resource "aws_lambda_function" "placeholder_function" {
  function_name = "placeholder-function"
  timeout       = 5
  image_uri     = "020278250508.dkr.ecr.eu-west-2.amazonaws.com/placeholder:1.0.0"
  package_type  = "Image"
  role = aws_iam_role.placeholder_function_role.arn
  tags = {
    Owner = "Ilia Petrov"
  }
}

resource "aws_iam_role" "placeholder_function_role" {
  name = "placeholder_function_role"
  assume_role_policy = file("assume_role_policy.json")
  tags = {
    Owner = "Ilia Petrov"
  }
}
