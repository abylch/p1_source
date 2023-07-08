# Create a DNS record for the EC2 instance
resource "aws_route53_record" "j_record" {
  depends_on = [aws_instance.terra_ec2]
  zone_id = "Z000523520EIRHBODB1EF"
  name    = "j.qamonkeys.com"
  type    = "A"
  ttl     = "300"
  records = [aws_instance.terra_ec2.public_ip]
  
}
