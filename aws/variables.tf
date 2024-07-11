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