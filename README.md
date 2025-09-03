# Criação da Golden Image do Azure DevOps Agent

-----

## Objetivo

Este projeto tem como objetivo principal automatizar a criação de uma **Golden Image (AMI)** para os agentes de build do Azure DevOps. A automação é executada de forma autônoma no **CloudShell**, criando uma nova AMI base e, em seguida, atualizando o grupo de autoescalabilidade (Auto Scaling Group) de pré-produção para que os novos agentes possam ser testados nos pipelines.

## Execução

Para rodar a automação, siga os passos abaixo:

1.  Abra o AWS **CloudShell**. 
2.  Crie um novo script shell, por exemplo, `run.sh`.
3.  Copie o conteúdo do **Secrets Manager** do caminho `cloudshell/automation` e cole-o dentro do arquivo `run.sh`.
4.  Após colar o conteúdo, salve o arquivo e conceda permissão de execução:
    ```bash
    chmod +x run.sh
    ```
5.  Execute o script com o comando `source`:
    ```bash
    source run.sh
    ```

## O que o script faz?

Ao ser executado, o script `run.sh` realizará as seguintes ações:

1.  **Instalação do Packer:** O script fará a instalação do **Packer** no CloudShell, que é a ferramenta utilizada para criar a AMI.
2.  **Download dos scripts:** Fará o download dos scripts de configuração necessários para o agente do Azure DevOps.
3.  **Modificação dos scripts:** Os scripts de configuração serão modificados para garantir que a AMI seja criada com a configuração desejada para os agentes.
4.  **Execução do Packer:** O Packer será executado para construir a AMI, seguindo as configurações definidas.
5.  **Atualização dos recursos AWS:** Após a criação da AMI, o script utilizará a **AWS CLI** para atualizar o `Launch Template` e o `Auto Scaling Group` de pré-produção, garantindo que os novos agentes sejam utilizados nos pipelines de teste.
