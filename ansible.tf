resource "ansible_host" "terra_ec2" {
  depends_on = [aws_instance.terra_ec2, aws_route53_record.j_record]
  name = aws_instance.terra_ec2.public_ip
  groups = ["all"]
  variables = {
    ansible_user = "ubuntu",
    ansible_ssh_private_key_file = "~/.ssh/terra_key",
    ansible_python_interpreter   = "/usr/bin/python3"
  }

  provisioner "remote-exec" {

    connection {
      host        = aws_instance.terra_ec2.public_ip
      type        = "ssh"
      user        = "ubuntu"
      private_key = tls_private_key.pk.private_key_pem
    }

    inline = [
          "sudo apt update -y",
          "echo 'Waiting...'",
          "sleep 120",
          "echo 'updated @@@@&#*%(^^&)^$%#$@!'",
          "echo Done!, status running"
    ]

  }

  # provisioner "local-exec" {
  #   working_dir = "/mnt/c/Users/abylc/terraform/p1/p1_source"
  #   command     = "ansible-inventory -i inventory.yml --graph --vars"
  # }

  # provisioner "local-exec" {
  #   working_dir = "/mnt/c/Users/abylc/terraform/p1/p1_source"
  #   command     = "ansible-playbook -i inventory.yml docker.yml"
  # }

  # provisioner "local-exec" {
  #   working_dir = "/mnt/c/Users/abylc/terraform/p1/p1_source"
  #   command     = "ansible-playbook -i inventory.yml jenkins.yml"
  # }


}


