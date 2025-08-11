output "bastion" {
  value = aws_instance.bastion.public_ip
}

output "jenkins-master-elb" {
  value = aws_elb.jenkins_elb.dns_name
}