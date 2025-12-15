output "bucket_arn" {
  value = aws_s3_bucket.bucket.arn #The ARN of the S3 bucket
}

output "bucket_name" { # Output the bucket name so the root module can reference it
  value = aws_s3_bucket.bucket.id
}