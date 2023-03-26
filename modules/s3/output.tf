output "s3_bucket" {
  value = aws_s3_bucket.main.bucket
}

output "iam_profile_id" {
  value = aws_iam_instance_profile.main.id
}