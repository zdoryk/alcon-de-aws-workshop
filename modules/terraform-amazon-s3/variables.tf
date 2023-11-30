
variable "bucket_base_name" {}
variable "s3_object_name" {}
variable "s3_object_source" {}
variable "upload_object" {
  description = "Determines whether to upload the object to the S3 bucket"
  type = bool
  default = false
}
