# Owncloud + EC2 + Terraform + Docker
Base do projeto:

Terraform: Terraform é uma infraestrutura de código aberto como ferramenta de software de código criada pela HashiCorp. Ele permite que os usuários definam e provisionem uma infraestrutura de datacenter usando uma linguagem de configuração de alto nível conhecida como Hashicorp Configuration Language, ou opcionalmente JSON.

AWS(EC2): Amazon Elastic Compute Cloud é uma parte central da plataforma de cloud computing da Amazon.com, Amazon Web Services. O EC2 permite que os usuários aluguem computadores virtuais nos quais rodam suas próprias aplicações.

Ubuntu 18.06: Ubuntu é um sistema operacional ou sistema operativo de código aberto, construído a partir do núcleo Linux, baseado no Debian e utiliza GNOME como ambiente de desktop de sua mais recente versão com suporte de longo prazo. É desenvolvido pela Canonical Ltd.

Docker: Docker é um software contêiner da empresa Docker, Inc, que fornece uma camada de abstração e automação para virtualização de sistema operacional no Windows e no Linux,[1][2] usando isolamento de recurso do núcleo do Linux como cgroups e espaços de nomes do núcleo, e um sistema de arquivos com recursos de união, como OverlayFS[3] criando contêineres independentes para executar dentro de uma única instância do sistema operacional, evitando a sobrecarga de manter máquinas virtuais (VM).

Owncloud: Cloud é um sistema de computador mais conhecido como "serviço de armazenamento e sincronização de arquivos".

SQLite: SQLite é uma biblioteca em linguagem C que implementa um banco de dados SQL embutido. Programas que usam a biblioteca SQLite podem ter acesso a banco de dados SQL sem executar um processo SGBD separado.
     
# Arquivos:

Owncloud.tf

credential

# Terraform:

Arquivo credencial para acesso entre Aws e Terraform(Local).

credential:

    [docker]
    aws_access_key_id = "XXXXXXXXXXXXXXX"
    aws_secret_access_key = "XXXXXXXXXXXXXXXXXXX"

Arquivo Terraform com toda programação da criação do ambiente.

Owncloud.tf:

Configurações iniciais, neste trecho fazemos conexão e seleção da região: 

    # Configuração Base para criação de uma Instancia EC2(AWS).
    provider "aws" {
    #Definição de Região
    region  = "us-east-1"
    #Arquivo com credenciais para acesso ao EC2
    shared_credentials_file = "/home/sistemas/.aws/credentials"
    #Nome do Profile de criação
    profile = "docker"
    }
	
Configuracões da instancia, aqui fazemos seleção da imagem, tamanho de disco, tipo da instancia e seleção das configurações de rede:

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

Criação de grupo de segurança, basicamente as configurações de firewall:

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

# Maos a obra!!!

Apos todo o codigo entendido vamos aplicas usando terraform

Baixando plugins da Aws com o comando

    terraform init

Revisando todo conteudo que sera aplicado ao Aws

    terraform plan

Aplicando todo codigo ao Aws

    terraform apply
    
        
