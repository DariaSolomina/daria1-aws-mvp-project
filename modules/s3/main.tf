# ---------------------------------------
# S3 Bucket Resource
# ---------------------------------------

resource "aws_s3_bucket" "bucket" {
  bucket = var.bucket_name
}

# ---------------------------------------
# Enforce Server-Side Encryption
# ---------------------------------------

resource "aws_s3_bucket_server_side_encryption_configuration" "encryption" {
  bucket = aws_s3_bucket.bucket.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256" # Specifies the use of AES256 encryption
    }
  }
}

# ---------------------------------------
# Enable Versioning
# ---------------------------------------

resource "aws_s3_bucket_versioning" "versioning" {
  bucket = aws_s3_bucket.bucket.id

  versioning_configuration {
    status = var.enable_versioning ? "Enabled" : "Suspended" # Enable or disable versioning dynamically
  }
}

# ---------------------------------------
# Block Public Access
# ---------------------------------------

resource "aws_s3_bucket_public_access_block" "public_access" {
  bucket = aws_s3_bucket.bucket.id # Blocking all public access unless explicitly enabled

  block_public_acls       = var.block_public_access
  block_public_policy     = var.block_public_access
  ignore_public_acls      = var.block_public_access
  restrict_public_buckets = var.block_public_access
}

# ---------------------------------------
# Lifecycle Rules (Optional)
# ---------------------------------------

resource "aws_s3_bucket_lifecycle_configuration" "lifecycle" {
  bucket = aws_s3_bucket.bucket.id # Associate lifecycle settings with the bucket

  rule {
    id     = "logs-lifecycle" # A unique identifier for the rule
    status = "Enabled"        # Replaces "enabled = true"

    filter {
      prefix = "logs/" # Specify the object prefix to filter lifecycle rules
    }
    transition {
      days          = 30
      storage_class = "GLACIER" # Move data to Glacier after 30 days
    }

    expiration {
      days = 365 # Permanently delete objects after 1 year
    }
  }
}