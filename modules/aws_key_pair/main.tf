resource "aws_key_pair" "master-key" {
  key_name   = var.key_name
  public_key = file(var.path_to_file)
}