module "deployment" {
  source  = "registry.terraform.io/l4gdev/codedeploy-ecr/aws"
  version = "1.2.3"

  subnet_ids = ["subnet-xxxx", "subnet-xxxx", "subnet-xxxx"]
  vpc_id     = "vpc-xxxx"

  repository = {
    branch = "main"
    name   = "my-awesome-app"
  }

  resource_to_deploy = ["module.app"]
  region             = data.aws_region.current.name
  tfstate_bucket     = "mybucket"

  build_envs = {
    IMAGE_REPO_URL  = "aws_ecr_repository.app.repository_url"
    DOCKER_BUILDKIT = "1"
  }

  build_configuration = {
    build_timeout      = "300"
    compute_type       = "BUILD_GENERAL1_SMALL"
    encrypted_artifact = true
    image              = "aws/codebuild/amazonlinux2-x86_64-standard:4.0"
    terraform_version  = "1.3.3"
  }

  application_name          = "my-awesome-app"
  environment_name          = "staging"
  pipeline_artifacts_bucket = "build-artefacts-${data.aws_caller_identity.current.account_id}"

}

data "aws_region" "current" {}
data "aws_caller_identity" "current" {}
