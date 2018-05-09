variable "region" {
  description = "My preferred region"
  default = "ap-northeast-2"
}
variable "base_image" {
  description = "Base image for ec2 instance"
  #default =  "ami-16c06c78"  #ubuntu with docker
  #ubuntu/images/hvm-ssd/ubuntu-xenial-16.04-amd64-server-20171026.1 (ami-7b1cb915)
  #描述 Canonical, Ubuntu, 16.04 LTS, amd64 xenial image build on 2017-10-26
  #default = "ami-7b1cb915"  # has problem???
  #default = "ami-e307ae8d"
  #default = "ami-69f85807" # python2 included, price

  #选择 64 位
  #ubuntu/images/hvm-ssd/ubuntu-xenial-16.04-amd64-server-20180306 - ami-a414b9ca
  #Canonical, Ubuntu, 16.04 LTS, amd64 xenial image build on 2018-03-06
  #根设备类型: ebs 虚拟化类型: hvm
  #default = "ami-a414b9ca"

  default = "ami-0f06af61" # my base
  default = "ami-fc06af92" # my docker preinstall base
}

provider "aws" {
  version = "~> 1.16"
  region = "${var.region}"
}

resource "aws_security_group" "ssh" {
  name = "ssh-sg"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  tags {
    Name = "ssh-sg"
  }
}

resource "aws_security_group" "inet" {
  name = "inet-sg"

  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
  }
  
  tags {
    Name = "inet-sg"
  }
}

# EC2 instance
resource "aws_instance" "labaws" {
  ami           = "${var.base_image}"
  instance_type = "t2.micro"
  vpc_security_group_ids = ["${aws_security_group.ssh.id}", "${aws_security_group.inet.id}"]
  key_name = "aws-gateway"

  user_data = <<-EOF
    #!/bin/bash
    echo "Hello aws with terraform!"
    EOF

  provisioner "local-exec" {
    command = "sudo gsed -i 's/^.* lab.aws/${self.public_ip} lab.aws/g' /etc/hosts"
  }

  tags {
    Name = "labaws"
  }
}

output "public_ip" {
  value = "${aws_instance.labaws.public_ip}"
}
