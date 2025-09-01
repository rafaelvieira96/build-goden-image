# Golden AMI Pipeline com Packer + Terraform

Este projeto implementa um fluxo de **criação e atualização de Golden AMIs** para uso em Auto Scaling Groups (ASG) na AWS, utilizando **Packer** para construir a imagem e **Terraform** para atualizar o Launch Template (LT) e disparar um Instance Refresh.

---

## 📦 Estrutura do Projeto

```
.
├── packer/
│   ├── al2-golden.pkr.hcl   # Template do Packer
│   └── scripts/
│       └── install.sh       # Script de instalação de pacotes
└── terraform/
    ├── main.tf              # Atualiza Launch Template e ASG
    ├── variables.tf
    └── outputs.tf
```

---

## ⚙️ Pré-requisitos

- [Packer](https://developer.hashicorp.com/packer/install) >= 1.10  
- [Terraform](https://developer.hashicorp.com/terraform/install) >= 1.6  
- AWS CLI configurado (`aws configure`) com credenciais válidas  
- Permissões necessárias:
  - Criar e registrar AMIs (Packer)
  - Atualizar Launch Template
  - Atualizar Auto Scaling Group e iniciar Instance Refresh

---

## 🚀 Fluxo Operacional

### 🔹 1. Construção da AMI com Packer

1. Entre na pasta `packer`:
   ```bash
   cd packer
   ```

2. Inicialize os plugins:
   ```bash
   packer init .
   ```

3. Execute o build, informando a AMI base:
   ```bash
   packer build -var "base_ami_id=ami-xxxxxxxx" .
   ```

4. Ao final, o **ID da AMI gerada** é salvo em `manifest.json`:
   ```bash
   cat manifest.json | jq -r '.builds[0].artifact_id' | cut -d: -f2
   ```

   > Exemplo de saída: `ami-0abc123def456ghij`

---

### 🔹 2. Atualização do Launch Template e ASG com Terraform

1. Entre na pasta `terraform`:
   ```bash
   cd ../terraform
   ```

2. Inicialize o Terraform:
   ```bash
   terraform init
   ```

3. Crie um arquivo `terraform.tfvars` com os valores:
   ```hcl
   region                 = "sa-east-1"
   launch_template_name   = "meu-lt-existente"
   autoscaling_group_name = "meu-asg-existente"
   new_ami_id             = "ami-0abc123def456ghij" # saída do Packer
   ```

4. Importe o Auto Scaling Group existente:
   ```bash
   terraform import 'aws_autoscaling_group.this' meu-asg-existente
   ```

5. Aplique as mudanças:
   ```bash
   terraform apply
   ```

---

## 🔄 O que acontece no Terraform

- Cria uma **nova versão do Launch Template** apontando para a nova AMI.  
- Atualiza o **ASG** para usar essa nova versão.  
- Dispara automaticamente um **Instance Refresh** (rolling update), substituindo as instâncias gradualmente.

---

## 📌 Notas Importantes

- **Rollback:** basta rodar novamente o `terraform apply` apontando para a versão anterior do Launch Template.  
- **Azure DevOps Agent:** o `install.sh` contém placeholders; configure conforme sua org/token/pool.  
- **Limpeza:** Packer gera snapshots associados à AMI. Caso remova AMIs antigas, também apague seus snapshots.  
- **Multi-Region:** para usar em múltiplas regiões, execute o fluxo separadamente em cada uma ou adapte o Packer para builds multi-region.

---

## ✅ Checklist antes de rodar

- [ ] Definiu a **AMI base** no comando do Packer.  
- [ ] Ajustou **nome do Launch Template** e **ASG** no `terraform.tfvars`.  
- [ ] Conseguiu capturar o `ami-xxxx` no `manifest.json`.  
- [ ] Importou o ASG existente para o estado do Terraform.  
