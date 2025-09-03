# Criação da Golden Image do Azure DevOps Agent - Conta Porto-k8s

-----

## Objetivo

Este projeto tem como objetivo principal automatizar a criação de uma **Golden Image (AMI)** para os agentes de build do Azure DevOps. A automação é executada de forma autônoma no **CloudShell**, criando uma nova AMI base e, em seguida, atualizando o grupo de autoescalabilidade (Auto Scaling Group) de pré-produção para que os novos agentes possam ser testados nos pipelines.

## Execução

Para rodar a automação, siga os passos abaixo:

1.  Abra o AWS **CloudShell**. 
2.  Crie um novo script shell, por exemplo, `bootstrap.sh`.
3.  Copie o conteúdo do **Secrets Manager** do caminho `cloudshell/automation` e cole-o dentro do arquivo `run.sh`.
4.  Após colar o conteúdo, salve o arquivo e conceda permissão de execução:
    ```bash
    chmod +x bootstrap.sh
    ```
5.  Execute o script com o comando `source`:
    ```bash
    source bootstrap.sh
    ```

## O que o script faz?

Ao ser executado, o script `bootstrap.sh` realizará as seguintes ações:

1.  **Instalação do Packer:** O script fará a instalação do **Packer** no CloudShell, que é a ferramenta utilizada para criar a AMI.
2.  **Download dos scripts:** Fará o download dos scripts de configuração necessários para o agente do Azure DevOps.
3.      - `agent.sh` Esse arquivo é o user-data da Ec2 que será criada. Ele é responsável por ativar o Agent do AzureDevops
4.      - `install.sh` Esse arquivo faz instalações base diretamente na AMI que sera utilizada
5.  **Modificação dos scripts:** Os scripts de configuração serão modificados para garantir que a AMI seja criada com a configuração desejada para os agentes.
6.  **Execução do Packer:** O Packer será executado para construir a AMI, seguindo as configurações definidas.
7.  **Atualização dos recursos AWS:** Após a criação da AMI, o script utilizará a **AWS CLI** para atualizar o `Launch Template` e o `Auto Scaling Group` de pré-produção, garantindo que os novos agentes sejam utilizados nos pipelines de teste.

## k9s

1. Baixe a versão mais recente do K9s
   
```
curl -s https://api.github.com/repos/derailed/k9s/releases/latest \
grep "browser_download_url.*Linux_x86_64.tar.gz" \
cut -d '"' -f 4 \
xargs curl -LO
```

Esse comando baixa o tar.gz mais novo para Linux x86_64.
Se estiver em Graviton (ARM64), troque x86_64 por arm64.

2. Extraia e instale
   
```
tar -xzf k9s_Linux_*.tar.gz
sudo mv k9s /usr/local/bin/
```

3. Teste
   
k9s version


