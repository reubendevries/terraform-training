output "Jenkins-Main-Node-Public-IP" {
  value = aws_instance.jenkins-master.public_ip
}

output "Jenkins-Worker-Public-Ips" {
  value = {
    for instance in aws_instance.jenkins-worker :
    instance.id => instance.public_ip
  }
}

output "LB-DNS-Name" {
  value = aws_alb.application-lb.dns_name
}

output "url" {
  value = aws_route53_record.jenkins.fqdn
}
