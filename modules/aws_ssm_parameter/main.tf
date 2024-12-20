data "aws_ssm_parameter" "JenkinsMasterAmi" {
  name     = var.name_ami
}
