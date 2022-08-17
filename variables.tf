variable "application_name" {
  type        = string
  description = "Name of your service, should be unique across repository."
}

variable "environment_name" {
  type        = string
  description = "Name of your deployment environment. For example; sandbox, staging, production."
}

variable "vpc_id" {
  type = string
}

variable "subnet_ids" {
  type = list(string)
}

variable "logs_retention_in_days" {
  type        = number
  default     = 0
  description = "Specifies the number of days you want to retain log events in the specified log group. Possible values are: 1, 3, 5, 7, 14, 30, 60, 90, 120, 150, 180, 365, 400, 545, 731, 1827, 3653, and 0. If you select 0, the events in the log group are always retained and never expire."
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
    image              = string
    terraform_version  = string
    encrypted_artifact = bool

  })
  default = {
    build_timeout      = "300"
    compute_type       = "BUILD_GENERAL1_SMALL"
    encrypted_artifact = true
    image              = "aws/codebuild/amazonlinux2-x86_64-standard:3.0"
    terraform_version  = "1.2.6"
  }
}

variable "custom_build_spec" {
  type        = string
  default     = ""
  description = "AWS codebuild build spec"
}

variable "build_envs" {
  type        = map(string)
  description = "key -> value definition for example {REGION: \"eu-west-1\"}"
}

variable "pipeline_artifacts_bucket" {
  type = string
}

variable "codestar_connection_arn" {
  type        = string
  description = "An ARN for AWS codestar connection (eg for github)"
  validation {
    condition     = can(regex("^arn:aws:codestar-connections:[^:\n]*:[[:digit:]]{12}:connection/.+", var.codestar_connection_arn))
    error_message = "Codestar connection must start with letter, only contain letters, numbers, dashes, or underscores and must be between 1 and 64 characters."
  }
}

variable "tags" {
  type        = map(string)
  default     = {}
  description = "Additional tags (e.g. '{'BusinessUnit': 'XYZ'}`). Neither the tag keys nor the tag values will be modified by this module."
}


variable "resource_to_deploy" {
  type    = list(string)
  default = []
}

variable "region" {
  type = string
}

variable "tfstate_bucket" {
  type    = string
  default = ""
}
variable "tf_backend_region" {
  type    = string
  default = ""
}