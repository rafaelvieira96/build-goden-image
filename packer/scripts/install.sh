#!/usr/bin/env bash
set -euo pipefail

# Atualiza pacotes
sudo dnf -y update

# Java 21/17/8 (Corretto)
sudo yum install java-1.8.0-amazon-corretto -y
sudo yum install java-17-amazon-corretto -y
sudo yum install java-21-amazon-corretto -y
sudo alternatives --set java /usr/lib/jvm/java-1.8.0-amazon-corretto.x86_64/jre/bin/java

# Maven
sudo yum install maven -y

# Docker   
## https://repost.aws/questions/QU1jeKaTRYQ7WeA7XobfP21g/how-do-i-install-docker-version-27-3-1-on-amazon-linux-2023

# Remove old version
sudo dnf remove -y docker docker-client docker-client-latest docker-common docker-latest docker-latest-logrotate docker-logrotate docker-engine
# Install dnf plugin
sudo dnf -y install dnf-plugins-core
# Add CentOS repository
sudo dnf config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
# Adjust release server version in the path as it will not match with Amazon Linux 2023
sudo sed -i 's/$releasever/9/g' /etc/yum.repos.d/docker-ce.repo
# Install as usual
sudo dnf -y install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
# Enable the docker service
sudo systemctl enable --now docker

# AWS CLI v2 (remove antigo e instala mais recente)
sudo dnf -y remove awscli || true
cd /tmp
curl -sSLo awscliv2.zip "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip"
unzip -q awscliv2.zip
sudo ./aws/install --update
aws --version || true

# k9s
#cd /usr/local/bin
#K9S_VER=$(curl -s https://api.github.com/repos/derailed/k9s/releases/latest | grep tag_name | cut -d'"' -f4)
#curl -sL "https://github.com/derailed/k9s/releases/download/${K9S_VER}/k9s_Linux_amd64.tar.gz" -o k9s.tgz
#sudo tar -xzf k9s.tgz k9s && sudo chmod +x k9s && rm -f k9s.tgz
#k9s version || true

# Azure DevOps Agent (placeholder)

# Define as variáveis de configuração
export AZP_URL="SEC_AZP_URL"
export AZP_TOKEN="SEC_AZP_TOKEN"
export AZP_POOL="SEC_AZP_POOL"
export AZP_AGENT_NAME="portok8s-pipelines"

# Define o caminho do diretório onde o agente será instalado
# Altere para o caminho desejado, se necessário
AGENT_DIR="/home/ubuntu/azp-agen"

# Cria o diretório e entra nele
mkdir -p "$AGENT_DIR"
cd "$AGENT_DIR"

# Baixa o agente (se ainda não estiver baixado)
# Baixa o agente (se ainda não estiver baixado)
if [ ! -f "vsts-agent-linux-x64-*.tar.gz" ]; then
    echo "Baixando o pacote do agente..."
    # A URL do agente pode variar, verifique a mais recente no Azure DevOps
    wget https://download.agent.dev.azure.com/agent/4.260.0/vsts-agent-linux-x64-4.260.0.tar.gz
    tar zxvf vsts-agent-linux-x64-4.260.0.tar.gz
fi

# Executa o script de configuração de forma não interativa
echo "Configurando o agente..."
./config.sh \
--unattended \
--url "$AZP_URL" \
--auth pat \
--token "$AZP_TOKEN" \
--pool "$AZP_POOL" \
--agent "$AZP_AGENT_NAME" \
--acceptTeeEula \
--work _work

echo "Configuração do agente concluída."

# Instala o agente como um serviço systemd para rodar em background
echo "Instalando o agente como um serviço..."
sudo ./svc.sh install
sudo ./svc.sh start

echo "Serviço do agente iniciado com sucesso."


