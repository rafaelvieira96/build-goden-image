#!/usr/bin/env bash
set -euo pipefail

# Atualiza pacotes
sudo dnf -y update

# Java 21/17/8 (Corretto)
sudo dnf -y install java-21-amazon-corretto \
                    java-17-amazon-corretto \
                    java-1.8.0-amazon-corretto

# Maven
sudo dnf -y install maven

# Docker
sudo dnf -y install docker
sudo systemctl enable --now docker
sudo usermod -aG docker ec2-user || true

# AWS CLI v2 (remove antigo e instala mais recente)
sudo dnf -y remove awscli || true
cd /tmp
curl -sSLo awscliv2.zip "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip"
unzip -q awscliv2.zip
sudo ./aws/install --update
aws --version || true

# k9s
cd /usr/local/bin
K9S_VER=$(curl -s https://api.github.com/repos/derailed/k9s/releases/latest | grep tag_name | cut -d'"' -f4)
curl -sL "https://github.com/derailed/k9s/releases/download/${K9S_VER}/k9s_Linux_amd64.tar.gz" -o k9s.tgz
sudo tar -xzf k9s.tgz k9s && sudo chmod +x k9s && rm -f k9s.tgz
k9s version || true

# Azure DevOps Agent (placeholder)
echo ">> Placeholder: instalar/configurar Azure DevOps Agent"
# Exemplo (comentei; ajuste conforme seu ambiente):
# sudo useradd -m -s /bin/bash azagent || true
# sudo -iu azagent bash -lc '
#   mkdir -p ~/agent && cd ~/agent
#   curl -sSLo agent.tar.gz https://vstsagentpackage.azureedge.net/agent/3.240.1/vsts-agent-linux-x64-3.240.1.tar.gz
#   tar -xzf agent.tar.gz
#   ./bin/installdependencies.sh
#   ./config.sh --unattended --url https://dev.azure.com/ORG --auth pat --token XXXXX --pool Default --agent $(hostname) --acceptTeeEula
#   sudo ./svc.sh install
#   sudo ./svc.sh start
# '
