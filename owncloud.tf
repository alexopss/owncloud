# Configure the AWS Provider
provider "aws" {
region  = "us-east-1"
shared_credentials_file = "/home/sistemas/.aws/credentials"
profile = "docker"
}
resource "aws_instance" "docker" {
  	#Imagem AWS
  	ami = "ami-0ac80df6eff0e70b5"
  	#Tipo da Intancia(Memoria, Processador)
  	instance_type = "t2.micro"
  	#Grupo de seguranca(Regras de firewall)
 	 vpc_security_group_ids = ["${aws_security_group.ssh.id}"]
  	#Chave de acesso para a conexão remota
 	 key_name = "docker"
  	#Configuracao sub_net
  	subnet_id  = "subnet-27fe9c6a"
  	#Configuração do disco
  	root_block_device {
    	volume_size              = "15"
    	volume_type              = "standard"
  }

  tags = {
    Name = "docker"
  }
  connection {
    type        = "ssh"
    user        = "ubuntu"
    private_key = file("~/.aws/docker.pem")
    host        = self.public_ip
  }
  provisioner "remote-exec" {
    inline = [
      "sudo apt-get update && sudo apt install docker.io -y && sudo docker run -d -p 80:80 owncloud:8.1"
    ]
  }
}

resource "aws_security_group" "ssh" {
	name = "allow_ssh"
	description = "Allow SSH connections"
	
	ingress {
		from_port = 22
		to_port = 22
		protocol = "tcp"
		cidr_blocks = ["0.0.0.0/0"]
	}
	ingress {
      		from_port   = 80
      		to_port     = 80
      		protocol    = "tcp"
      		cidr_blocks = ["0.0.0.0/0"]
	}
	egress {
    		from_port   = 0
   		to_port     = 0
   		protocol    = "-1"
   		cidr_blocks = ["0.0.0.0/0"]
  }
}
output "docke_public_dns"{
	value = "${aws_instance.docker.public_dns}"
}
