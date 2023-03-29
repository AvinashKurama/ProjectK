resource "aws_s3_bucket" "b" {
  bucket = "mybucket-kurama"

  tags = {
    Name        = "My bucket"
    Environment = "web"
  }
}

resource "aws_s3_bucket_acl" "example" {
  bucket = aws_s3_bucket.b.id
  acl    = "private"
}

terraform {
  backend "s3" {
    bucket     = "mybucket-kurama"
    key        = "path/tf_statefile"
    region     = "ap-south-1"
    access_key = "AKIAV6RCB7AIAYGBKGDR"
    secret_key = "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"
  }
}




