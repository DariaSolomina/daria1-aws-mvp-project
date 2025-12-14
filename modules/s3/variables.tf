variable "bucket_name" {} # The desired name of the S3 bucket. # Note: S3 bucket names must be globally unique across all AWS accounts.

variable "enable_versioning" { #Set to true to enable versioning for the S3 bucket
  default     = true
}

variable "block_public_access" { #Set to true to block public access to the S3 bucket
  default     = true
}