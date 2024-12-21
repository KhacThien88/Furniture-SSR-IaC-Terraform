
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
user_data = base64encode(<<-EOT
#!/bin/bash
echo "root:111111aA@" | chpasswd
sed -i 's/^#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config
sed -i 's/^PasswordAuthentication no/PasswordAuthentication yes/' /etc/ssh/sshd_config
sed -i 's/^#PubkeyAuthentication yes/PubkeyAuthentication no/' /etc/ssh/sshd_config
sed -i 's/^#ChallengeResponseAuthentication yes/ChallengeResponseAuthentication no/' /etc/ssh/sshd_config
systemctl restart ssh 
systemctl restart sshd 
systemctl restart sshd.service 
EOT
)

  tags = {
    Name = var.tag
  }
}
