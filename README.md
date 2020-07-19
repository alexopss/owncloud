# Owncloud
Projeto baseado em Terraform.

Estrutura:
Terraform

AWS(EC2)

Ubuntu 18.06

Docker

Owncloud

SQLite
     
# Terraform:

Owncloud.tf

credential

credential:

    [docker]
    aws_access_key_id = "XXXXXXXXXXXXXXX"
    aws_secret_access_key = "XXXXXXXXXXXXXXXXXXX"

Owncloud.tf:

Configurações Iniciais:

    # Configuração Base para criação de uma Instancia EC2(AWS).
    provider "aws" {
    #Definição de Região
    region  = "us-east-1"
    #Arquivo com credenciais para acesso ao EC2
    shared_credentials_file = "/home/sistemas/.aws/credentials"
    #Nome do Profile de criação
    profile = "docker"
    }
	
Configuracões da Instancia:

    #Configuração iniciais para criação da instancia.
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

Tag de Nomeação da Instancia:

    tags = {
    Name = "Docker"
    }
    
Conexão via SSH a instancia criada na aws:

    connection {
    type        = "ssh"
    user        = "ubuntu"
    #Chave extraido na Aws
    private_key = file("~/.aws/docker.pem")
    host        = self.public_ip
    }
    
Execusao remota a instacia para criação do Docker e Container Owncloud:
	
    provisioner "remote-exec" {
    inline = [
    "sudo apt-get update && sudo apt install docker.io -y && sudo docker run -d -p 80:80 owncloud:8.1"
    ]
    }

Criação de grupo de segurança:

    resource "aws_security_group" "ssh" {
    name = "allow_ssh"
    description = "Allow SSH connections"
	
Criação liberações de acesso(Firewall):
Entrada SSH:

    ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    idr_blocks = ["0.0.0.0/0"]
	}
	
Entrada Http:

    ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
	}
	
Saida Full:

    egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    }
    
Retorno de Endereço do dns no console do Terraform:

    output "docke_public_dns"{
	value = "${aws_instance.docker.public_dns}"
    }
