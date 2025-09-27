# Wordpress-AWS
Projeto na AWS com Wordpress com alta disponibilidade.
-----
Etapa 1 - Criando a rede (VPC, Subnets, Rotas, IGW e Nat)

  1.1 Acesse o console da AWS e no campo de busca, digite "VPC". Selecione o serviço VPC.

- No painel lateral, clique em "Your VPCs" e em seguida em "Create VPC".

- Na seção "VPC settings", selecione a opção: ✓ VPC and more (para criação automática de todos os componentes de rede)

- Configure os parâmetros da VPC:

  - Name tag auto-generation: wordpress-projeto
  - IPv4 CIDR block: 10.0.0.0/16
  - IPv6 CIDR block: No IPv6 CIDR block
  - Number of Availability Zones (AZs): 2
  - Number of public subnets: 2
  - Number of private subnets: 4
  - NAT gateways: 1 per AZ
  - VPC endpoints: None
  - DNS options: Mantenha as opções padrão
  - Clique em "Create VPC".

<img width="1335" height="548" alt="image" src="https://github.com/user-attachments/assets/7aaad650-a87d-4844-9b93-3c5b59ac0e6a" />

<img width="1366" height="493" alt="image" src="https://github.com/user-attachments/assets/57950de6-81ce-42fd-b954-c191b60ac71a" />

A AWS criará automaticamente:
- 1 VPC
- 6 subnets (2 públicas + 4 privadas)
- 1 Internet Gateway (IGW)
- 2 NAT Gateways (um em cada AZ)
- Tabelas de rotas configuradas

Etapa 1.2 - Validação das Subnets
- Acesse "VPC" > "Subnets"
- Filtro pela VPC recém criada (wordpress-projeto-vpc)
- Confirme a criação das 6 subnets com a seguinte estrutura:

- wordpress-subnet-public1-us-east-1a  | us-east-1a | Pública  | 10.0.0.0/20    |
- wordpress-subnet-public2-us-east-1b  | us-east-1b | Pública  | 10.0.16.0/20   |
- wordpress-subnet-private1-us-east-1a | us-east-1a | Privada  | 10.0.128.0/20  |
- wordpress-subnet-private2-us-east-1b | us-east-1b | Privada  | 10.0.144.0/20  |
- wordpress-subnet-private3-us-east-1a | us-east-1a | Privada  | 10.0.160.0/20  |
- wordpress-subnet-private4-us-east-1b | us-east-1b | Privada  | 10.0.176.0/20  |

* Verifique se as subnets estão corretas e se as subnets públicas tem acesso a internet.

Etapa 1.3 - Verificação do IGW
- Acesse VPC > Internet Gateways.
- Localize o IGW criado automaticamente: wordpress-projeto-igw.
- Verifique se o Estado está como "Attached" e se a VPC de associação é a wordpress-projeto-vpc.

![1 3 verificando o igw](https://github.com/user-attachments/assets/349416a0-b385-4e42-b154-8fa015acb5c7)

Etapa 1.4 - Verificação da Tabela de Rotas
- Acesse VPC > Route Tables.
- Filtre pela VPC wordpress-projeto-vpc.
- Verifique as tabelas criadas:
- Tabela pública: deve ter uma rota para 0.0.0.0/0 apontando para o IGW.
- Tabelas privadas: devem ter uma rota para 0.0.0.0/0 apontando para o NAT Gateway da respectiva AZ.

![1 4 tabela de rrotas](https://github.com/user-attachments/assets/e75d992b-0a66-4d6a-bc75-7a63f5adc9cf)

Etapa 1.5 - Validação do Nat Gateway 
- Acesse VPC > NAT Gateways.
- Verifique a existência de dois NAT Gateways, um em cada AZ:
- wordpress-projeto-nat-public1-us-east-1a
- wordpress-projeto-nat-public2-us-east-1b
- Confirme que cada um possui um Elastic IP associado e que o Estado é "Available".
- Para validar os IPs elásticos, acesse VPC > Elastic IPs. Você deve visualizar dois IPs alocados e associados aos NAT Gateways.

![1 5 nat gateway](https://github.com/user-attachments/assets/46faffb2-a99f-4339-b20d-c9c2e4346a25)

-----

Etapa 2 - Criação dos Securitys Groups
2.1 Vá em "VPC" > "Security Group" e clique em "Criar Security Group"
  - Configurações básicas:
  - Security group name: SG-LoadBalancer
  - Description: sg para application load balancer público
  - VPC: Selecione wordpress-projeto-vpc
  - Regras de entrada (Inbound rules):
  - Clique em "Add rule" e configure:
    - Type: HTTP
    - Protocol: TCP
    - Port range: 80
    - Source: 0.0.0.0/0 (Qualquer lugar-IPv4)
    - Description: Acesso HTTP público
    - Regras de saída (Outbound rules):
    - Mantenha a regra padrão:
    - Destination: 0.0.0.0/0
    - Clique em "Create security group"

![2 criação dos sg - load balancer](https://github.com/user-attachments/assets/384cbadb-4c5b-4413-b216-ef9bad8ff407)

    
Faça o mesmo processo de nomear, colocar descrição e selecionar a VPC correta para cada Security Group. Atenção, cada SG terá sua própria regra de entrada/saída que serão detalhadas abaixo:

Etapa 2.2 SG Bastion Host:
Regras de entrada (Inbound rules):
- Clique em "Add rule" e configure:
- Type: SSH
- Protocol: TCP
- Port range: 22
- Source: My IP (Seu endereço IP atual)

Regras de saída (Outbound rules):
- Mantenha a regra padrão

Etapa 2.3 SG da EC2:
Criar um grupo de segurança restritivo que permita apenas:
Tráfego HTTP do Load Balancer
Acesso SSH apenas do Bastion Host
Acesso na porta 8080 apenas do seu IP (para testes)

Regras de entrada (Inbound rules):

- 1ª Regra:
- Type: HTTP 
- Protocol: TCP
- Port range: 80
- Source: Selecione SG-LoadBalancer (Security Group do ALB)

2ª Regra:
- Type: Custom TCP
- Protocol: TCP
- Port range: 8080
- Source: My IP

3ª Regra:
- Type: SSH
- Protocol: TCP
- Port range: 22
- Source: Selecione SG-BastionHost (Security Group do Bastion Host)

Regras de saída (Outbound rules):
- Mantenha a regra padrão: 0.0.0.0/0

Etapa 2.4 SG para o RDS

Regras de entrada (Inbound rules):
- Type: MySQL/Aurora
- Protocol: TCP
- Port range: 3306
- Source: Selecione SG-EC2-WordPress (Security Group das EC2)

Regras de saída (Outbound rules):
- Mantenha as regras padrão

Etapa 2.5 - SG para o EFS
Regras de entrada (Inbound rules):
- Type: NFS
- Protocol: TCP
- Port range: 2049
- -Source: Selecione SG-EC2-WordPress (Security Group das EC2)

Regras de saída (Outbound rules):
- Mantenha as regras padrão

Foram criados com sucesso todos os grupos de segurança necessários para a arquitetura:
Grupo de Segurança	Finalidade	Regras de Entrada Principais
- SG-LoadBalancer	ALB público	HTTP (80) de 0.0.0.0/0
- SG-BastionHost	Acesso administrativo	SSH (22) apenas do seu IP
- SG-EC2-WordPress	Instâncias WordPress	HTTP do ALB + SSH do Bastion
- SG-RDS-MySQL	Banco de dados	MySQL (3306) apenas das EC2
- SG-EFS-FileSystem	Sistema de arquivos	NFS (2049) apenas das EC2

Esta configuração garante o princípio do menor privilégio, onde cada serviço só pode se comunicar com os recursos estritamente necessários para o funcionamento da aplicação.

----

Etapa 3 - Criação do RDS (Relational Database Service)
Etapa - 3.1 Criando a subr-rede do banco de dados

Criar um grupo de sub-redes dedicado para o RDS, permitindo que o banco de dados seja implantado em sub-redes privadas distribuídas em diferentes zonas de disponibilidade.

- Acesse o console da AWS e digite "RDS" no campo de busca.
- No painel lateral, clique em "Subnet groups" sob a seção "Configuração".
- Clique em "Create DB subnet group".
- Configurações básicas:

  - Name: rds-subnet-group

  - Description: Grupo de sub-redes para RDS do projeto WordPress

  - VPC: Selecione wordpress-projeto-vpc

  - Seleção de zonas de disponibilidade e sub-redes:

  - Availability Zones: Selecione us-east-1a e us-east-1b

  - Subnets: Selecione as sub-redes privadas dedicadas ao RDS:

  - wordpress-projeto-subnet-private3-us-east-1a (10.0.160.0/20)

  - wordpress-projeto-subnet-private4-us-east-1b (10.0.176.0/20)

Clique em "Create".

Etapa 3.2 - Criação da instância do Bando de Dados RDS
No RDS, na laterial aperte em "Database" no painel lateral e clique em "Criar Database".
#Configurações Iniciais:#
Escolha o modo de criação:
- Standard create (Criação padrão)
  - Engine options:
  - Engine type: MySQL
  - Edition: MySQL Community
  - Version: Deixe a versão padrão (ex: MySQL 8.0.42)

#Configurações de Template e Disponibilidade
- Templates:
  - Free tier (Nível gratuito)
  - Availability and durability:
  - Single-AZ DB instance (1 instância) - Devido às restrições da conta educacional

#Configurações da Instância#
Settings:
- DB instance identifier: wordpress-db
- Master username: admin (ou outro usuário de sua preferência)
- Master password:
  - Auto generate a password (recomendado) OU Manage master credentials in AWS Secrets Manager

#Configuração de Instância e Armazenamento#
DB instance configuration:
DB instance class: db.t3.micro (selecionado automaticamente pelo free tier)
Storage:
- Storage type: General Purpose (SSD) - gp2
- Allocated storage: 20 GB
- Enable storage autoscaling
- Maximum storage threshold: 1000 GB

#Conectividade#
- Resource of compute: Don't connect to an EC2 compute resource
- Virtual Private Cloud (VPC): wordpress-projeto-vpc
- DB subnet group: rds-subnet-group (criado anteriormente)
- Public access: No (⚠️ CRÍTICO - manter o banco privado)
- VPC security group: Choose existing
- Existing VPC security groups: Selecione SG-RDS-MySQL
- Availability Zone: us-east-1a 

#Configurações Adicionais#
Additional configuration:
- Initial database name: wordpressdb
- DB parameter group: default.mysql8.0
- Option group: default.mysql-8-0
  - Enable automatic backups (recomendado para produção)
  - Enable encryption (criptografia ativada por padrão)
- AWS KMS key: (default) aws/rds

Após clicar em "Criar banco de dados", o provisionamento será iniciado. Aguarde alguns minutos até que o status do banco de dados mude de "Criando" para "Disponível" antes de prosseguir.

----

Etapa 4 - Criação do Amazon EFS
Sua implementação é essencial para garantir a persistência e consistência dos dados em arquiteturas com mais de uma instância. 

Etapa 4.1 - 

<img width="740" height="632" alt="image" src="https://github.com/user-attachments/assets/c83ffc13-8222-4785-bf2d-2cc748d61c44" />

Clique em "Personalizar:

<img width="1359" height="494" alt="image" src="https://github.com/user-attachments/assets/a53dc984-4a25-46ee-97df-773fe1357653" />
