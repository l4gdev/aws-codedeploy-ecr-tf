
##############################################################
# CodeStar - account-provisioning-customizations
##############################################################


resource "aws_codepipeline" "codestar_account_provisioning_customizations" {
  name     = lower("${var.labels.tags.Environment}-${var.labels.tags.Service}-Build-and-deploy")
  role_arn = aws_iam_role.codepipeline_role.arn

  artifact_store {
    location = var.s3_artifact_store
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
      provider         = "CodeStarSourceConnection"
      version          = "1"
      output_artifacts = ["repo"]

      configuration = {
        ConnectionArn        = aws_codestarconnections_connection.github.arn
        FullRepositoryId     = var.repository.name
        BranchName           = var.repository.branch
        DetectChanges        = true
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
