output "pipeline_name" {
  description = "CodePipeline name"
  value       = aws_codepipeline.app.name
}

output "codebuild_project_name" {
  description = "CodeBuild project name"
  value       = aws_codebuild_project.app.name
}