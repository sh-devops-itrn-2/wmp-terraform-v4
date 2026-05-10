resource "aws_instance" "instance" {
  for_each = var.components
  ami           = "ami-0220d79f3f480ecf5"
  instance_type = "t3.micro"
  vpc_security_group_ids = ["sg-03f7da9ebe210e12a"]
  tags = {
    Name = each.key
  }
}

resource "aws_route53_record" "dns" {
  for_each  =  var.components
  zone_id = "Z03351562OJATKDWYEO40"
  name    = "${each.key}-dev"
  type    = "A"
  ttl     = 30
  records = [aws_instance.instance[each.key].private_ip]
}

variable "components" {
    default = {
      frontend = ""
      postgresql = ""
      auth-service = ""
      portfolio-service = ""
      analytics-service = ""
    }
}

resource "null_resource" "ansible" {

  for_each = var.components
  provisioner "remote-exec" {

    connection {
      type     = "ssh"
      host     = aws_instance.instance[each.key].public_ip
      user     = "ec2-user"
      password = "DevOps321"
    }
    inline = [
      "sudo labauto ansible",
      "ansible-pull -i localhost, -U https://github.com/sh-devops-itrn-2/wmp-terraform-v4.git main.yml -e env=dev -e COMPONENT=${each.key}"
    ]
  }
}




