output "user_pool" {
	value = aws_cognito_user_pool.user_pool.id
}

output "user_pool_client_id" {
	value = aws_cognito_user_pool_client.user_pool_client.id
}

output "bucket_name" {
	value = aws_s3_bucket.bucket.bucket
}
