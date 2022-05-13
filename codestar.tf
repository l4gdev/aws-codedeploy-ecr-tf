resource "aws_codestarconnections_connection" "github" {
  name          = "${var.labels.tags.Environment}-${var.labels.tags.Service}"
  provider_type = "GitHub"
}
