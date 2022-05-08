resource "aws_s3_bucket" "store" {
  bucket = lower("${var.labels.tags.Environment}-${var.labels.tags.Service}-test-bucket-to-store-build-data")
}