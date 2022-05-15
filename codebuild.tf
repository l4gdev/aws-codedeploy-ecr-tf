data "local_file" "docker_build_buildspec" {
  filename = "${path.module}/buildspecs/docker-build.yml"
}

locals {
  default_build_envs = {
    AWS_DEFAULT_REGION = data.aws_region.current.name
    AWS_ACCOUNT_ID     = tostring(data.aws_caller_identity.current.account_id)
  }
  build_envs = merge(merge(local.default_build_envs, var.build_envs), var.labels.tags)
  build_spec = var.custom_build_spec == "" ? data.local_file.docker_build_buildspec.content : var.custom_build_spec
}


resource "aws_codebuild_project" "build" {
  depends_on    = [aws_cloudwatch_log_group.account_provisioning_customizations]
  name          = "${var.labels.tags.Environment}-${var.labels.tags.Service}-build"
  description   = "Build docker for ${var.labels.tags.Service}"
  build_timeout = var.build_configuration.build_timeout
  service_role  = aws_iam_role.build.arn
  tags          = var.tags

  artifacts {
    type                = "CODEPIPELINE"
    encryption_disabled = !var.build_configuration.encrypted_artifact
  }

  environment {
    compute_type                = var.build_configuration.compute_type
    image                       = var.build_configuration.image
    type                        = "LINUX_CONTAINER"
    image_pull_credentials_type = "CODEBUILD"
    privileged_mode             = true
    dynamic "environment_variable" {
      for_each = local.build_envs
      content {
        name  = environment_variable.key
        value = environment_variable.value
      }
    }
  }

  logs_config {
    cloudwatch_logs {
      group_name = aws_cloudwatch_log_group.account_provisioning_customizations.name
    }
  }

  source {
    type      = "CODEPIPELINE"
    buildspec = local.build_spec
  }

  vpc_config {
    vpc_id             = var.vpc_id
    subnets            = var.subnet_ids
    security_group_ids = [aws_security_group.builder.id]
  }

}

resource "aws_codebuild_project" "terraform_apply" {
  depends_on    = [aws_cloudwatch_log_group.account_provisioning_customizations]
  name          = "${var.labels.tags.Environment}-${var.labels.tags.Service}-terraform-apply"
  description   = "Apply Terraform"
  build_timeout = var.build_configuration.build_timeout
  service_role  = aws_iam_role.build.arn
  tags          = var.tags
  artifacts {
    type                = "CODEPIPELINE"
    encryption_disabled = !var.build_configuration.encrypted_artifact
  }

  environment {
    compute_type                = var.build_configuration.compute_type
    image                       = var.build_configuration.image
    type                        = "LINUX_CONTAINER"
    image_pull_credentials_type = "CODEBUILD"
    privileged_mode             = true

    dynamic "environment_variable" {
      for_each = local.build_envs
      content {
        name  = environment_variable.key
        value = environment_variable.value
      }
    }
  }

  logs_config {
    cloudwatch_logs {
      group_name = aws_cloudwatch_log_group.account_provisioning_customizations.name
    }
  }

  source {
    type = "CODEPIPELINE"
    buildspec = templatefile("${path.module}/buildspecs/terraform-runner.yml", {
      TF_VERSION        = "1.1.7"
      TF_BACKEND_REGION = "eu-west-1"
      REGION            = "eu-west-1"
      TF_S3_BUCKET      = "terraform-state-${data.aws_caller_identity.current.account_id}"
      TF_S3_KEY         = "${var.labels.tags.Environment}/${var.labels.tags.Service}.tfstate"
      SERVICE           = var.labels.tags.Service
      ENVIRONMENT       = var.labels.tags.Environment
      TAGS              = jsonencode(var.tags)
    })
  }

  vpc_config {
    vpc_id             = var.vpc_id
    subnets            = var.subnet_ids
    security_group_ids = [aws_security_group.builder.id]
  }

}

resource "aws_security_group" "builder" {
  name        = "${var.labels.tags.Environment}-${var.labels.tags.Service}-CodeBuild"
  description = "test"
  vpc_id      = var.vpc_id
  egress = [
    {

      description      = "for all outgoing traffics"
      from_port        = 0
      to_port          = 0
      protocol         = "-1"
      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = ["::/0"]
      prefix_list_ids  = []
      security_groups  = []
      self             = false
    }
  ]
  tags = {
    Name = "Build"
  }
}

resource "aws_cloudwatch_log_group" "account_provisioning_customizations" {
  name              = "/aws/codebuild/${var.labels.tags.Environment}/${var.labels.tags.Service}/build-logs"
  retention_in_days = var.log_group_retention
  tags              = var.tags
}


