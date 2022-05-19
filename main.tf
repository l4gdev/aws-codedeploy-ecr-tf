locals {
  tags = merge({
    Environment = var.environment_name
    Service     = var.application_name
  }, var.tags)
  default_build_envs = {
    AWS_DEFAULT_REGION = data.aws_region.current.name
    AWS_ACCOUNT_ID     = tostring(data.aws_caller_identity.current.account_id)
  }
  build_envs = merge(merge(local.default_build_envs, var.build_envs), local.tags)
  build_spec = var.custom_build_spec == "" ? data.local_file.docker_build_buildspec.content : var.custom_build_spec
}
