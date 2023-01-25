
##############################################################
# CodeStar - account-provisioning-customizations
##############################################################


resource "aws_codepipeline" "codestar_account_provisioning_customizations" {
  name     = lower("${var.environment_name}-${var.application_name}-Build-and-deploy")
  role_arn = aws_iam_role.codepipeline_role.arn
  tags     = var.tags

  artifact_store {
    location = var.pipeline_artifacts_bucket
    type     = "S3"
  }

  ##############################################################
  # Source
  ##############################################################
  stage {
    name = "Source"

    action {
      name             = "Pull-sourcecode"
      category         = "Source"
      owner            = "AWS"
      provider         = var.codestar_connection_arn != null ? "CodeStarSourceConnection" : "CodeCommit"
      version          = "1"
      output_artifacts = ["repo"]

      configuration = {
        ConnectionArn        = var.codestar_connection_arn != null ? var.codestar_connection_arn : null
        FullRepositoryId     = var.codestar_connection_arn != null ? var.repository.name : null
        RepositoryName       = var.codestar_connection_arn != null ? null : var.repository.name
        BranchName           = var.repository.branch
        DetectChanges        = var.codestar_connection_arn != null ? true : null
        OutputArtifactFormat = "CODE_ZIP"
      }
    }
  }

  stage {
    name = "Build-docker"

    action {
      name             = "Build-and-push-app-container"
      category         = "Build"
      owner            = "AWS"
      provider         = "CodeBuild"
      input_artifacts  = ["repo"]
      output_artifacts = ["build_output"]
      version          = "1"
      run_order        = "2"
      configuration = {
        ProjectName = aws_codebuild_project.build.name
      }
    }
  }

  stage {
    name = "Terraform-apply"

    action {
      name             = "Terraform-apply"
      category         = "Build"
      owner            = "AWS"
      provider         = "CodeBuild"
      input_artifacts  = ["repo", "build_output"]
      output_artifacts = ["terraform_apply_output"]
      version          = "1"
      run_order        = "3"
      configuration = {
        ProjectName   = aws_codebuild_project.terraform_apply.name
        PrimarySource = "repo"
      }
    }
  }



}
