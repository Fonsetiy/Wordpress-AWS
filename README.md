# <img src="https://cdn-icons-png.flaticon.com/512/174/174881.png" width="25"/> Projeto Wordpress DevOpsSec 2025 | Wordpress em alta disponibilidade na AWS

## Descrição do Projeto 
Este projeto consiste na implantação de uma arquitetura altamente disponível e escalável para a plataforma WordPress na Amazon Web Services (AWS). A solução foi desenvolvida para garantir resiliência, performance e segurança, simulando um ambiente de produção capaz de suportar interrupções sem impactar a disponibilidade da aplicação.

## 🎯  Principais Objetivos
- Alta Disponibilidade: Garantir uptime de 99.9%+ através de distribuição multi-AZ

- Escalabilidade Automática: Ajustar capacidade automaticamente conforme a demanda

- Segurança Robusta: Implementar princípios de segurança em camadas

- Tolerância a Falhas: Continuidade operacional mesmo durante falhas de componentes

- Otimização de Custos: Utilizar recursos de forma eficiente com auto-scaling

## 🏗️ Diagrama do Sistema
A imagem abaixo representa a arquitetura principal do projeto WordPress na AWS, focado em alta disponibilidade e escalabilidade.


<img width="936" height="411" alt="undefined" src="https://github.com/user-attachments/assets/07102d97-61fc-40d9-a2b0-153c92afe2cf" />


## 🛠️ Tecnologias Utilizadas
[![AWS](https://img.shields.io/badge/AWS-232F3E?style=for-the-badge&logo=amazonaws&logoColor=white)](https://aws.amazon.com/)
[![EC2](https://img.shields.io/badge/Amazon%20EC2-FF9900?style=for-the-badge&logo=amazonec2&logoColor=white)](https://aws.amazon.com/ec2/)
[![RDS MySQL](https://img.shields.io/badge/Amazon%20RDS-527FFF?style=for-the-badge&logo=amazonrds&logoColor=white)](https://aws.amazon.com/rds/)
[![Auto Scaling](https://img.shields.io/badge/Auto%20Scaling-FF4F8B?style=for-the-badge&logo=amazonaws&logoColor=white)](https://aws.amazon.com/autoscaling/)
[![Amazon EFS](https://img.shields.io/badge/Amazon%20EFS-FF9900?style=for-the-badge&logo=amazonaws&logoColor=white)](https://aws.amazon.com/efs/)
[![WordPress](https://img.shields.io/badge/WordPress-21759B?style=for-the-badge&logo=wordpress&logoColor=white)](https://wordpress.org/)
[![VS Code](https://img.shields.io/badge/VS%20Code-007ACC?style=for-the-badge&logo=visualstudiocode&logoColor=white)](https://code.visualstudio.com/)
[![Docker](https://img.shields.io/badge/Docker-2496ED?style=for-the-badge&logo=docker&logoColor=white)](https://www.docker.com/)
[![Docker Compose](https://img.shields.io/badge/Docker%20Compose-2496ED?style=for-the-badge&logo=docker&logoColor=white)](https://docs.docker.com/compose/)
[![Bash](https://img.shields.io/badge/Shell_Bash-121011?style=for-the-badge&logo=gnubash&logoColor=white)](https://www.gnu.org/software/bash/)
[![Load Balancer](https://img.shields.io/badge/Application%20Load%20Balancer-FF4F8B?style=for-the-badge&logo=amazonaws&logoColor=white)](https://aws.amazon.com/elasticloadbalancing/)
[![Ubuntu 24.04](https://img.shields.io/badge/Ubuntu%2024.04-E95420?style=for-the-badge&logo=ubuntu&logoColor=white)](https://ubuntu.com/)
[![GitHub](https://img.shields.io/badge/GitHub-181717?style=for-the-badge&logo=github&logoColor=white)](https://github.com/)
[![Launch Template](https://img.shields.io/badge/Launch%20Template-FF9900?style=for-the-badge&logo=amazonaws&logoColor=white)](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/ec2-launch-templates.html)
[![Amazon VPC](https://img.shields.io/badge/Amazon%20VPC-FF9900?style=for-the-badge&logo=amazonaws&logoColor=white)](https://aws.amazon.com/vpc/)

## Etapas do Projeto
1. Criação da rede (VPC, Subnets, Nat Gateway, IGW).
2. Grupos de Segurança.
3. Criação o Relational Database Service (RDS).
4. Criação o Elastic File System (EFS).
5. Criação do Launch Template
6. Criação o Application Load Balancer (ALB).
7. Criação o Auto Scaling Group (ASG)
-------

### ▶️ Etapa 1 - Criando a rede (VPC, Subnets, Rotas, IGW e Nat)
Permite criar uma rede virtual isolada dentro da AWS, onde você define sub-redes, tabelas de rotas, gateways e regras de firewall (security groups e ACLs). É como criar sua própria infraestrutura de rede, mas em nuvem.

### 🔹 Etapa 1.1 - Acesse o console da AWS e no campo de busca, digite "VPC". Selecione o serviço VPC.

- No painel lateral, clique em "Your VPCs" e em seguida em "Create VPC".

- Na seção "VPC settings", selecione a opção: ✓ VPC and more (para criação automática de todos os componentes de rede)

- Configure os parâmetros da VPC:

  - Nome: wordpress-projeto
  - IPv4 CIDR block: `10.0.0.0/16`
  - IPv6 CIDR block: `No IPv6 CIDR block`
  - Number of Availability Zones (AZs): `2`
  - Number of public subnets: `2`
  - Number of private subnets: `4`
  - NAT gateways: `1 per AZ`
  - VPC endpoints: None
  - DNS options: Mantenha as opções padrão
  - Clique em "Create VPC".

<img width="1335" height="548" alt="image" src="https://github.com/user-attachments/assets/7aaad650-a87d-4844-9b93-3c5b59ac0e6a" />

<img width="1366" height="493" alt="image" src="https://github.com/user-attachments/assets/57950de6-81ce-42fd-b954-c191b60ac71a" />

#### A AWS criará automaticamente:

- 1 VPC
- 6 subnets (2 públicas + 4 privadas)
- 1 Internet Gateway (IGW)
- 2 NAT Gateways (um em cada AZ)
- Tabelas de rotas configuradas

### 🔹 Etapa 1.2 - Validação das Subnets

- Acesse "VPC" > "Subnets"
- Filtro pela VPC recém criada (wordpress-projeto-vpc)
- Confirme a criação das 6 subnets com a seguinte estrutura:

- `wordpress-subnet-public1-us-east-1a  | us-east-1a | Pública  | 10.0.0.0/20    |`
- `wordpress-subnet-public2-us-east-1b  | us-east-1b | Pública  | 10.0.16.0/20   |`
- `wordpress-subnet-private1-us-east-1a | us-east-1a | Privada  | 10.0.128.0/20  |`
- `wordpress-subnet-private2-us-east-1b | us-east-1b | Privada  | 10.0.144.0/20  |`
- `wordpress-subnet-private3-us-east-1a | us-east-1a | Privada  | 10.0.160.0/20  |`
- `wordpress-subnet-private4-us-east-1b | us-east-1b | Privada  | 10.0.176.0/20  |`

**Verifique se as subnets estão corretas e se as subnets públicas tem acesso a internet.**

### 🔹 Etapa 1.3 - Verificação do IGW
- Acesse VPC > Internet Gateways.
- Localize o IGW criado automaticamente: `wordpress-projeto-igw.`
- Verifique se o Estado está como "Attached" e se a VPC de associação é a wordpress-projeto-vpc.

![1 3 verificando o igw](https://github.com/user-attachments/assets/349416a0-b385-4e42-b154-8fa015acb5c7)


### 🔹 Etapa 1.4 - Verificação da Tabela de Rotas
- Acesse VPC > Route Tables.
- Filtre pela VPC wordpress-projeto-vpc.
- Verifique as tabelas criadas:
- Tabela pública: deve ter uma rota para 0.0.0.0/0 apontando para o IGW.
- Tabelas privadas: devem ter uma rota para 0.0.0.0/0 apontando para o NAT Gateway da respectiva AZ.

**Tabela de Rotas da Private 1a**

![ROTA 1A](https://github.com/user-attachments/assets/81746690-ddd0-4e0b-8435-70699f364483)

**Tabela de Rotas da Private 1b**

![ROTA 1B](https://github.com/user-attachments/assets/7b928942-be0b-4958-9f29-15c56c1c8506)

**Tabela de Rotas da Public**

![ROTA PUBLIC](https://github.com/user-attachments/assets/8d3875b4-72f3-4206-b541-f4da646184a1)


### 🔹Etapa 1.5 - Validação do Nat Gateway 
- Acesse VPC > NAT Gateways.
- Verifique a existência de dois NAT Gateways, um em cada AZ:
    - wordpress-projeto-nat-public1-us-east-1a
    - wordpress-projeto-nat-public2-us-east-1b
- Confirme que cada um possui um Elastic IP associado e que o Estado é "Available".
- Para validar os IPs elásticos, acesse VPC > Elastic IPs. Você deve visualizar dois IPs alocados e associados aos NAT Gateways.

**NAT Gateway**
![1 5 nat gateway](https://github.com/user-attachments/assets/46faffb2-a99f-4339-b20d-c9c2e4346a25)

--------

### 🔹 Etapa 2 - Criação dos Securitys Groups
São firewalls virtuais que controlam o tráfego de entrada e saída para seus recursos AWS. Funcionam como porteiros inteligentes que só permitem tráfego autorizado.

### 🔹 Etapa 2.1 - Criação do Security Group do Load Balancer

Vá em "VPC" > "Security Group" e clique em "Criar Security Group"
  - Configurações básicas:
  - Security group name: SG-LoadBalancer
  - Description: sg para application load balancer público
  - VPC: Selecione wordpress-projeto-vpc

  **Regras de entrada (Inbound rules):**
  - Clique em "Add rule" e configure:
    - Type: `HTTP`
    - Protocol: `TCP`
    - Port range: `80`
    - Source: `0.0.0.0/0` (Qualquer lugar-IPv4)
    - Description: Acesso HTTP público
    
  **Regras de saída (Outbound rules):**
    - Mantenha a regra padrão:
    - Destination: 0.0.0.0/0
    - Clique em "Create security group"

![2 criação dos sg - load balancer](https://github.com/user-attachments/assets/384cbadb-4c5b-4413-b216-ef9bad8ff407)

    
Faça o mesmo processo de nomear, colocar descrição e selecionar a VPC correta para cada Security Group. Atenção, cada SG terá sua própria regra de entrada/saída que serão detalhadas abaixo:

### 🔹 Etapa 2.2 - Criação do Scurity Group do Bastion Host:
**Regras de entrada (Inbound rules):**
- Clique em "Add rule" e configure:
- Type: `SSH`
- Protocol: `TCP`
- Port range: `22`
- Source: `My IP` (Seu endereço IP atual)

**Regras de saída (Outbound rules):**
- Mantenha a regra padrão

### 🔹 Etapa 2.3 - Criação do Security Group da EC2:
**Regras de entrada (Inbound rules):**
- 1ª Regra:
- Type: `HTTP`
- Protocol: `TCP`
- Port range: `80`
- Source: Selecione `SG-LoadBalancer` (Security Group do ALB)

2ª Regra:
- Type: `Custom TCP`
- Protocol: `TCP`
- Port range: `8080`
- Source: `My IP`

3ª Regra:
- Type: `SSH`
- Protocol: `TCP`
- Port range: `22`
- Source: Selecione SG-BastionHost (Security Group do Bastion Host)

**Regras de saída (Outbound rules):**
- Mantenha a regra padrão: 0.0.0.0/0

### 🔹 Etapa 2.4 - Criação do Secuirity Group do RDS:
**Regras de entrada (Inbound rules):**
- Type: `MySQL/Aurora`
- Protocol: `TCP`
- Port range: `3306`
- Source: Selecione SG-EC2-WordPress (Security Group das EC2)

**Regras de saída (Outbound rules):**
- Mantenha as regras padrão

### 🔹 Etapa 2.5 - Criação do Security Group do EFS:
**Regras de entrada (Inbound rules):**
- Type: `NFS`
- Protocol: `TCP`
- Port range: `2049`
- Source: Selecione SG-EC2-WordPress (Security Group das EC2)

**Regras de saída (Outbound rules):**
- Mantenha as regras padrão
-----
Foram criados com sucesso todos os grupos de segurança necessários para a arquitetura:

| **Grupo de Segurança** | **Finalidade**           | **Regras de Entrada Principais**       |
|-------------------------|--------------------------|-----------------------------------------|
| SG-LoadBalancer         | ALB público              | HTTP (80) de `0.0.0.0/0`               |
| SG-BastionHost          | Acesso administrativo    | SSH (22) apenas do seu IP              |
| SG-EC2-WordPress        | Instâncias WordPress     | HTTP do ALB + SSH do Bastion           |
| SG-RDS-MySQL            | Banco de dados MySQL     | MySQL (3306) apenas das EC2            |
| SG-EFS-FileSystem       | Sistema de arquivos EFS  | NFS (2049) apenas das EC2              |

Esta configuração garante o princípio do menor privilégio, onde cada serviço só pode se comunicar com os recursos estritamente necessários para o funcionamento da aplicação.

----

###  ▶️ Etapa 3 - Criação do RDS (Relational Database Service)
Serviço gerenciado de banco de dados relacional. Suporta diversos motores, como MySQL, PostgreSQL, MariaDB, Oracle e SQL Server. A AWS cuida de tarefas como backups, atualização de software, replicação e alta disponibilidade.

### 🔹 Etapa 3.1 - Criando a sub-rede do banco de dados
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

    - `wordpress-projeto-subnet-private3-us-east-1a (10.0.160.0/20)`

    - `wordpress-projeto-subnet-private4-us-east-1b (10.0.176.0/20)`

![3 SUBNET dos rds](https://github.com/user-attachments/assets/7da40a5d-00a0-4e49-9458-2190408a3334)

Clique em "Create".

### 🔹 Etapa 3.2 - Criação da instância do Bando de Dados RDS
No RDS, na laterial aperte em "Database" no painel lateral e clique em "Criar Database".
**Configurações Iniciais:**
Escolha o modo de criação:
- Standard create (Criação padrão)
  - Engine options:
  - Engine type: `MySQL`
  - Edition: `MySQL Community`
  - Version: Deixe a versão padrão (ex: MySQL 8.0.42)
  
![3 1 CRIação do rds](https://github.com/user-attachments/assets/3db9a76e-5818-4a18-ad1a-9fd3862d9742)


![3 1 criação rds I](https://github.com/user-attachments/assets/0920d250-f3ea-4a57-89d1-96a62558a5da)


**Configurações de Template e Disponibilidade**
- Templates:
  - Free tier (Nível gratuito)
  - Availability and durability:
  - Single-AZ DB instance (1 instância) - Devido às restrições da conta educacional

![3 1 CRIAÇÃO RDS II](https://github.com/user-attachments/assets/951b4e25-7f4a-41b1-a322-ce29a95ec9cf)


**Configurações da Instância**
Settings:
- DB instance identifier: wordpress-db
- Master username: admin (ou outro usuário de sua preferência)
- Master password:
  - Auto generate a password (recomendado) OU Manage master credentials in AWS Secrets Manager

**Configuração de Instância e Armazenamento**
DB instance configuration:
- DB instance class: `db.t3.micro`
Storage:
- Storage type: General Purpose (SSD) - gp2
- Allocated storage: 20 GB
- Enable storage autoscaling
- Maximum storage threshold: 1000 GB


![3 1 RDS III](https://github.com/user-attachments/assets/45734500-c5a4-493d-bdba-43f6e5123d04)



![3 - IV](https://github.com/user-attachments/assets/2b258dc0-f4e4-4eba-a7f4-3bc4377394b8)


**Conectividade**
- Resource of compute: Don't connect to an EC2 compute resource
- Virtual Private Cloud (VPC): `wordpress-projeto-vpc`
- DB subnet group: `rds-subnet-group` (criado anteriormente)
- Public access: `No` (⚠️ CRÍTICO - manter o banco privado)
- VPC security group: Choose existing
  - Existing VPC security groups: Selecione SG-RDS
- Availability Zone: `us-east-1a`


![3 1 RDS V](https://github.com/user-attachments/assets/66821294-c0d1-42c4-9fe6-cdf74e7ed0d0)


**Configurações Adicionais**
Additional configuration:
- Initial database name: wordpressdb
- DB parameter group: `default.mysql8.0`
- Option group: default.mysql-8-0
  - Enable automatic backups : Deixe essa opção desmarcada para evitar custos.
  - Enable encryption (criptografia ativada por padrão)
- AWS KMS key: (default) aws/rds


![3 1 - VI](https://github.com/user-attachments/assets/5b831019-a4d5-4be1-a990-73b9ba300ff8)


Após clicar em "Criar banco de dados", o provisionamento será iniciado. Aguarde alguns minutos até que o status do banco de dados mude de "Criando" para "Disponível" antes de prosseguir.

------

### ▶️ Etapa 4 - Amazon EFS
Serviço de computação em nuvem que permite criar e gerenciar máquinas virtuais (instâncias) configuráveis de acordo com a necessidade do usuário. É altamente escalável e possibilita escolher sistema operacional, quantidade de CPU, memória, armazenamento e rede.
Sua implementação é essencial para garantir a persistência e consistência dos dados em arquiteturas com mais de uma instância. 

### 🔹 Etapa 4.1 - Criação do EFS
Acesse o console da AWS e digite "EFS" no campo de busca.
- Clique em "Create file system".

**Configurações Básicas**
- Nome do sistema de arquivos: wordpress-EFS
- Virtual Private Cloud (VPC):
- Selecione a VPC do projeto: `wordpress-projeto-vpc (vpc-0753151eae78ba4bd)`


![4 1 EFS ](https://github.com/user-attachments/assets/a78434e9-c032-4fc9-a749-6823c4e67e08)

- Clique em "Personalizar"

**Configurações de Disponibilidade**
- Tipo do sistema de arquivos:
  - Regional (Recomendado para alta disponibilidade)

  
![4 1 II](https://github.com/user-attachments/assets/67d4552e-eca0-4bf0-bad6-6af7797ae306)


**Configurações de Performance**
- Modo de taxa de transferência:
  - Elastic (Configuração padrão recomendada)

**Configurações de Lifecycle Management**
- Transição para Infrequent Access (IA): `Nenhum`
- Transição para Archive: `Nenhum`
- Transição para o padrão: `Nenhum`

**Configurações de Backup**
- Backups automáticos:
  - Habilitar backups automáticos - Deixar essa opção desmarcada (opcional -  se habilitar pode gerar custos adicionais).

**Configurações de Rede**
Network access:
- Mount targets: O EFS criará automaticamente pontos de montagem em todas as zonas de disponibilidade da VPC
- Security groups: Será necessário configurar posteriormente o security group criado anteriormente (SG-EFS-FileSystem)


![4 1 III](https://github.com/user-attachments/assets/5ccdf458-c7cf-42c9-a5b9-6816798688df)


De resto, pode manter as opções padrões.

- Clique em "Create".

------

### ▶️ Etapa 5 - Launch Template
O Launch Template atua como um modelo pré-configurado que define todas as especificações técnicas para a criação de instâncias EC2. Ele serve como base para o Auto Scaling Group, garantindo que cada nova instância provisionada automaticamente possua a mesma configuração, software e scripts de inicialização.

### 🔹 Etapa 5.1 - Criação do Launch Template
- Acesse o console da EC2:
- No painel de navegação, clique em "Launch Templates"
- Clique em "Create launch template"
  - Configurações Básicas:
    - Launch template name: wordpress-template
    - Marque a opção: Provide guidance to help me set up a template that I can use with EC2 Auto Scaling
- AMI (Amazon Machine Image):
- Application and OS Images: Selecione "Ubuntu Server 24.04 LTS"
- AMI ID: ami-0360c520857e313ff (64-bit x86)
  - Qualificado para o nível gratuito

 ![5 - MODELO de execuçao](https://github.com/user-attachments/assets/b1182955-d57f-40cc-b54b-e3d3d12dbaa4)


**Instance Type:**
- Instance type: `t2.micro`

![5 ii](https://github.com/user-attachments/assets/65c7d515-a1d7-47dd-b323-86a99b9700a3)



**Key Pair:**
- Key pair name: Selecione um par de chaves existente ou crie novo


![5  III](https://github.com/user-attachments/assets/fae4badb-b605-4287-90e2-3ee1a018b6f0)


**Network Settings:**
- Subnet: Deixe em branco (será definido no Auto Scaling Group)
- Firewall (security groups): Select existing security group
- Security groups: Selecione SG-EC2-WordPress


### 🔹 Etapa 5.2 - User Data
O script de User Data executa automaticamente na inicialização da instância, configurando todo o ambiente WordPress.
- Na seção "Advanced details", expanda "User data", selecione a opção "File" e faça upload do arquivo de script ou cole o script diretamente no campo de texto.

- ![5 1 USER DATA](https://github.com/user-attachments/assets/d3942138-5631-4776-bcd6-bcf576466b7a)


### 🔹 Etapa 5.3 - Validação 

Criação do Template:
- Clique em "Create launch template"
- Validação Pós-Criação:
- Acesse EC2 > Launch Templates
- Verifique se wordpress-template está listado
- Status deve ser "Available"

------

### ▶️ Etapa 6 - Conceito e configuração do Application Load Balancer (ALB)
O Application Load Balancer (ALB) atua como um distribuidor inteligente de tráfego que recebe as requisições HTTP/HTTPS dos usuários e as encaminha para as instâncias EC2 saudáveis do WordPress. Ele é essencial para garantir alta disponibilidade, escalabilidade e resiliência da aplicação.

### 🔹 Etapa 6.1 - Criação do Load Balancer
Acesse o console da EC2:
- No painel de navegação, clique em "Load Balancers"
- Clique em "Create Load Balancer"
- Seleção do Tipo:
  - Application Load Balancer
  - Clique em "Create"


![etapa 6 1 I](https://github.com/user-attachments/assets/3726101e-b3f8-4067-8ebf-e830bf7e4926)


**Configuração Básica:**
- Load balancer name: wordpress-alb
- Scheme: `Internet-facing` (voltado para internet)
- IP address type: `IPv4`


![6 1 II](https://github.com/user-attachments/assets/58348508-3f45-4cf4-8341-dfd4c997c22b)


**Configuração de Rede:**
  - VPC: Selecione wordpress-projeto-vpc
  - Mappings: Selecione pelo menos 2 zonas de disponibilidade com subnets públicas:
    - `us-east-1a: wordpress-projeto-subnet-public1-us-east-1a`
    - `us-east-1b: wordpress-projeto-subnet-public2-us-east-1b`


![6 III](https://github.com/user-attachments/assets/a46a2bdd-95c8-4125-b113-718c2f16d8f9)


**Configuração de Segurança:**
- Security groups: Selecione `SG-LoadBalancer`


![6 1 iv](https://github.com/user-attachments/assets/5aad0816-9dc6-430d-9f77-410a11a9d9f3)


- Verifique se permite tráfego `HTTP` na porta `80`


![6 1 V](https://github.com/user-attachments/assets/508e6322-f854-4305-8abe-a97fac9c9e4f)


### 🔹 Etapa 6.2 - Target Group 

**Configuração do Target Group**
- Na seção "Listeners and routing":
  - Protocol: `HTTP`
  - Port: `80`
  - Clique em "Create target group"

**Configurações Básicas do Target Group:**

- Choose a target type: `Instances`


![6 1 VI](https://github.com/user-attachments/assets/e40dd64e-0f02-46cd-b876-84f5fcde7a27)


- Target group name: wordpress-target-group
- Protocol: `HTTP`
- Port: `80`
- VPC: Selecione `wordpress-projeto-vpc`


![6 1 VII](https://github.com/user-attachments/assets/8ea30532-a055-4876-8624-1aaadf226a9d)


**Configurações Avançadas de Health Check:**
- Health check path: / (página inicial do WordPress)
- Health check port: Traffic port
- Healthy threshold: `2` (verificações consecutivas para considerar saudável)
- Unhealthy threshold: `2` (verificações consecutivas para considerar não-saudável)
- Timeout: `5 seconds`
- Interval: `30 seconds`
- Success codes: `200` (HTTP OK)


![6 1 VIII](https://github.com/user-attachments/assets/ee0c0a73-55c7-4bde-bb35-d767a49fcd68)


**Registro de Destinos:**
- Não selecione nenhuma instância manualmente
- O Auto Scaling Group registrará automaticamente as instâncias
- Clique em "Create target group"

**Associação com o ALB:**
- Volte à tela do ALB e atualize a lista de target groups
- Selecione o wordpress-target-group criado
- Action: Forward to wordpress-target-group


------ 


### ▶️ Etapa 7 - Auto Scaling Group
O Auto Scaling Group atua como um sistema de gestão automática de capacidade para a aplicação WordPress. Sua principal função é garantir que o ambiente mantenha sempre a quantidade ideal de servidores em operação, ajustando-se dinamicamente às variações de tráfego e mantendo a resiliência frente a eventuais falhas.

### 🔹 Etapa 7.1 - Criação do LG
Acesse o console da EC2:
- No painel de navegação, role até "Auto Scaling" e clique em "Auto Scaling Groups"
- Clique em "Create Auto Scaling group"


![ETAPA 7 I](https://github.com/user-attachments/assets/2e80747a-0b9f-4b21-a651-c7bd668ce693)


**Configurações Básicas:**
- Auto Scaling group name: wordpress-asg
- Launch template: Selecione wordpress-template
- Version: `Default (1)`


**Configuração de Rede:**
- VPC: Selecione wordpress-projeto-vpc
- Availability Zones and subnets: Selecione as subnets privadas em pelo menos 2 AZs:
    - `wordpress-projeto-subnet-private1-us-east-1a`
    - `wordpress-projeto-subnet-private2-us-east-1b`
- Availability Zone rebalancing: Balanceamento de melhor esforço


![ETAPA 7 II](https://github.com/user-attachments/assets/09636e42-09f1-4f87-8450-03669a2028d1)


**Configuração de Load Balancing:**
- Load balancing: Attach to an existing load balancer
- Existing load balancer target groups: Selecione wordpress-target-group
- Health checks: ELB health checks + EC2 health checks


![7 IV](https://github.com/user-attachments/assets/2f1b0ee0-6846-44b3-a2ab-963f2a042b41)


**Configurações de Health Check:**
- Enable Elastic Load Balancing health check
- Enable Amazon EBS health checks
- Health check grace period: `300 seconds`

**Definição de Capacidade Base**
- Capacity units: Instances
- Desired capacity: `2` (quantidade ideal de instâncias em operação normal)
- Minimum capacity: `2` (número mínimo de instâncias sempre ativas)
- Maximum capacity: `4` (limite máximo de expansão)


![7 V](https://github.com/user-attachments/assets/b985e5cc-f67f-4acd-8c41-727e37e251fa)


**Política de Escalabilidade Automática**
Para implementar um sistema de ajuste dinâmico de capacidade, configure uma política de target tracking:
- Scaling policy type: Target tracking scaling policy
- Metric type: Average CPU utilization
- Target value: `70` (percentual de uso de CPU alvo)
- Instance warm-up: `300 seconds` (período de estabilização)
- Selecione a opção "Enable group metrics collection within CloudWatch"

**Funcionamento da Política**
- Expansão: Se a utilização média de CPU exceder 70%, o ASG adiciona automaticamente novas instâncias
- Contração: Se a utilização ficar consistentemente abaixo de 70%, o ASG remove instâncias ociosas
- Estabilização: Novas instâncias aguardam 5 minutos antes de serem consideradas nas métricas

------

### ▶️ Etapa 8 - Testes
Nesta etapa, validamos o funcionamento completo da infraestrutura implantada. O site WordPress foi acessado via Application Load Balancer (ALB), garantindo balanceamento de carga entre as instâncias EC2.

### 🔹 Etapa 8.1
No console da EC2, navegue até "Load Balancers"
- Selecione o load balancer wordpress-alb
- Na seção "Description", copie o DNS name:
  ```wordpress-alb-xxxxxxxxx.us-east-1.elb.amazonaws.com```
- Acesse o DNS em seu navegador web

![8 1](https://github.com/user-attachments/assets/292557d9-6059-4c4a-a85b-5546a8d113b8)


![8 1 II](https://github.com/user-attachments/assets/61637449-009a-4016-b318-035361c43db4)

- Tela de Login do Wordpress:

![8 1 III](https://github.com/user-attachments/assets/97531548-fc17-48bc-a9da-7483ba112e89)

- Visual do site configurado:


![8 1 IV](https://github.com/user-attachments/assets/798df30a-a39a-4023-be3b-21964193b394)


----

### Próximos passos e Melhorias

- Automatizar a infraestrutura usando Terraform ou AWS CloudFormation.

- Criar dashboards detalhados no CloudWatch e configurar alertas para falhas ou picos de uso.

- Associar um domínio personalizado ao Load Balancer com Route 53.

- Ativar HTTPS no Load Balancer usando certificado do AWS Certificate Manager (ACM).
