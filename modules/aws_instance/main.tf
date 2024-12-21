
resource "aws_instance" "jenkins-master" {
  ami                         = var.ami
  instance_type               = var.instance-type
  key_name                    = var.key_name
  associate_public_ip_address = true
  vpc_security_group_ids      = [var.sg_id]
  subnet_id                   = var.subnet_id_1
#   provisioner "local-exec" {
#     command = <<EOF
# aws --profile ${var.profile} ec2 wait instance-status-ok --region ${var.region} --instance-ids ${self.id} 
# ansible-playbook --extra-vars 'passed_in_hosts=tag_Name_${self.tags.Name}' ${var.ansible_playbook_path}
# EOF
#   }

  tags = {
    Name = var.tag
  }
}
