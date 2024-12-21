 output "private_ip" {
   value = aws_instance.jenkins-master.private_ip
 }
 output "id" {
  value = aws_instance.jenkins-master.id
}

output "tags" {
  value = aws_instance.jenkins-master.tags
}
output "public_ip" {
  value = aws_instance.jenkins-master.public_ip
}
