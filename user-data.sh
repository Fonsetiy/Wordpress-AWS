#!/bin/bash
# Espera inicial para garantir que a maquina esteja pronta
sleep 45

# Atualizar pacotes e instalar dependencias essenciais
apt update -y -qq
apt install -y -qq apt-transport-https ca-certificates curl software-properties-common nfs-common

# Configurar chave e repositorio Docker
install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
chmod a+r /etc/apt/keyrings/docker.asc

ARCH=$(dpkg --print-architecture)
CODENAME=$(. /etc/os-release && echo "$VERSION_CODENAME")
echo "deb [arch=${ARCH} signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu ${CODENAME} stable" \
  | tee /etc/apt/sources.list.d/docker.list > /dev/null

apt update -y -qq
apt install -y -qq docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

# Iniciar e habilitar Docker
systemctl enable --now docker
usermod -aG docker ubuntu

# Configuracao do EFS
EFS_ID="SEU_EFS_IS"
AWS_REGION="SUA_ZONA"
EFS_MOUNT_POINT="/mnt/efs-wordpress"

mkdir -p ${EFS_MOUNT_POINT}
mount -t nfs4 -o nfsvers=4.1,rsize=1048576,wsize=1048576,hard,timeo=600,retrans=2,noresvport \
  ${EFS_ID}.efs.${AWS_REGION}.amazonaws.com:/ ${EFS_MOUNT_POINT}

# Garantir que EFS sera montado apos reboot
grep -qxF "${EFS_ID}.efs.${AWS_REGION}.amazonaws.com:/ ${EFS_MOUNT_POINT} nfs4 nfsvers=4.1,rsize=1048576,wsize=1048576,hard,timeo=600,retrans=2,noresvport,_netdev 0 0" /etc/fstab || \
echo "${EFS_ID}.efs.${AWS_REGION}.amazonaws.com:/ ${EFS_MOUNT_POINT} nfs4 nfsvers=4.1,rsize=1048576,wsize=1048576,hard,timeo=600,retrans=2,noresvport,_netdev 0 0" >> /etc/fstab

# Preparar diretorios do projeto WordPress
PROJECT_DIR="/home/ubuntu/wordpress-project"
WORDPRESS_FILES_PATH="${EFS_MOUNT_POINT}/html"

mkdir -p ${PROJECT_DIR} ${WORDPRESS_FILES_PATH}

# Variaveis do banco de dados
DB_HOST="ENDPOINT_DO_RDS"
DB_USER="SEU_USER"
DB_PASSWORD="<SUA SENHA>"
DB_NAME="NOME_DO_SEU_DATABSE"

# Criar docker-compose
cat <<EOF > ${PROJECT_DIR}/docker-compose.yml
version: '3.8'
services:
  wordpress:
    image: wordpress:php8.3-apache
    container_name: wordpress
    restart: always
    ports:
      - "80:80"
    environment:
      WORDPRESS_DB_HOST: ${DB_HOST}
      WORDPRESS_DB_USER: ${DB_USER}
      WORDPRESS_DB_PASSWORD: ${DB_PASSWORD}
      WORDPRESS_DB_NAME: ${DB_NAME}
    volumes:
      - ${WORDPRESS_FILES_PATH}:/var/www/html/

  phpmyadmin:
    image: phpmyadmin/phpmyadmin
    container_name: phpmyadmin
    restart: always
    ports:
      - "8080:80"
    environment:
      PMA_HOST: ${DB_HOST}
      PMA_PORT: 3306
EOF

# Ajustar permissoes e subir containers
chown -R 33:33 ${WORDPRESS_FILES_PATH}
cd ${PROJECT_DIR}
docker compose up -d > /dev/null 2>&1
