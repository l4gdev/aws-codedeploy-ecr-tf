variable "application_name" {
  type = string
}

variable "vpc_id" {
  type = string
}

variable "subnet_ids" {
  type = list(string)
}

variable "log_group_retention" {
  type = string
}

variable "repository" {
  type = object({
    name   = string,
    branch = string
  })
}

variable "build_configuration" {
  type = object({
    build_timeout      = string
    compute_type       = string
    encrypted_artifact = bool
    image              = string

  })
  default = {
    build_timeout      = "300"
    compute_type       = "BUILD_GENERAL1_SMALL"
    encrypted_artifact = true
    image              = "aws/codebuild/amazonlinux2-x86_64-standard:3.0"
    terraform_version  = "1.1.7"
  }
}

variable "labels" {
  type = object({
    tags = object({
      Environment = string
      Service     = string
    })
    name = string
  })
}

variable "custom_build_spec" {
  type        = string
  default     = ""
  description = "AWS codebuild build spec"
}

variable "build_envs" {
  type        = any
  description = "key -> value definition for example {REGION: \"eu-west-1\"}"
}

variable "s3_artifact_store" {
  type = string
}

variable "codestar_connection_arn" {
  type        = string
  description = "An ARN for AWS codestar connection (eg for github)"
  validation {
      condition     = can(regex("^arn:aws:codestar-connection:w+(?:-\\w+)+:[[:digit:]]{12}:connection/.+", var.codestar_connection_arn))
      error_message = "Codestar connection must start with letter, only contain letters, numbers, dashes, or underscores and must be between 1 and 64 characters."
    }
}

variable "tags" {
  type        = map(string)
  default     = {}
  description = "Additional tags (e.g. '{'BusinessUnit': 'XYZ'}`). Neither the tag keys nor the tag values will be modified by this module."
}