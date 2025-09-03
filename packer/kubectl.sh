echo ">>>>>>>>>>>>>>>>>>>>>>> Instalando kubectl"

KUBECTL_VERSION="1.33.3"
KUBECTL_DATE="2025-08-03"
curl -fsSL -o /usr/local/bin/kubectl \
  "https://s3.us-west-2.amazonaws.com/amazon-eks/${KUBECTL_VERSION}/${KUBECTL_DATE}/bin/linux/amd64/kubectl"

sudo chmod +x /usr/local/bin/kubectl
echo "kubectl instalado em /usr/local/bin"

# Verifica versão
kubectl version --client --output=yaml || true

echo ">>>>>>>>>>>>>>>>>>>>>>> Instalando k9s"

K9S_VERSION="v0.50.9"
curl -fsSL -o /tmp/k9s.tar.gz \
  "https://github.com/derailed/k9s/releases/download/${K9S_VERSION}/k9s_Linux_amd64.tar.gz"

tar -xzf /tmp/k9s.tar.gz -C /tmp
sudo mv /tmp/k9s /usr/local/bin/
sudo chmod +x /usr/local/bin/k9s
echo "k9s instalado em /usr/local/bin"

echo ">>>>>>>>>>>>>>>>>>>>>>> Configurando alias e completion para ec2-user"

EC2_HOME="/home/ec2-user"

# Garantir que o bash-completion esteja disponível
if [ -f /usr/share/bash-completion/bash_completion ]; then
  echo "if [ -f /usr/share/bash-completion/bash_completion ]; then" \
       "  . /usr/share/bash-completion/bash_completion" \
       "fi" >> "${EC2_HOME}/.bashrc"
fi

# Alias para kubectl
echo "alias k=kubectl" >> "${EC2_HOME}/.bashrc"
echo "complete -o default -F __start_kubectl k" >> "${EC2_HOME}/.bashrc"

# Ajusta permissões do .bashrc
chown ec2-user:ec2-user "${EC2_HOME}/.bashrc"

echo "Configuração do kubectl e k9s concluída!"
