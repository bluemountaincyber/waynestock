variable "region" {
  description = "The AWS region to deploy resources."
  type        = string
  default     = "us-east-2"
}

variable "stage" {
  description = "The stage of the API gateway deployment."
  type        = string
  default     = "api"
}

variable "backend_bucket" {
  description = "The S3 bucket to store the Terraform state file."
  type        = string
}

variable "backend_key" {
  description = "The key (path) within the S3 bucket to store the Terraform state file."
  type        = string
  default    = "terraform.tfstate"
}
