variable "bucket_name" {
  description = "The name of the S3 bucket (must be globally unique)"
  type        = string
}

variable "enable_versioning" {
  description = "Enable versioning for the S3 bucket"
  type        = bool
  default     = true
}

variable "block_public_access" {
  description = "Block public access to the S3 bucket"
  type        = bool
  default     = true
}

variable "lifecycle_prefix" {
  description = "Prefix for lifecycle rule filter"
  type        = string
  default     = ""
}

variable "lifecycle_glacier_days" {
  description = "Number of days before transitioning to Glacier"
  type        = number
  default     = 30
}

variable "lifecycle_expiration_days" {
  description = "Number of days before expiring objects"
  type        = number
  default     = 365
}

variable "tags" {
  description = "Tags for all resources"
  type        = map(string)
  default     = {}
}
