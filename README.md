# Desafio-Extra---Devops

# Terraform Azure Infrastructure

Este repositório contém um script Terraform para provisionar uma infraestrutura no Azure, incluindo uma máquina virtual com Docker e Docker Compose instalados.

## Pré-requisitos

1. **Instalar Terraform**: Siga as instruções no [site oficial do Terraform](https://learn.hashicorp.com/tutorials/terraform/install-cli) para instalar a versão mais recente do Terraform.
2. **Instalar Azure CLI**: Siga as instruções no [site oficial da Azure CLI](https://docs.microsoft.com/pt-br/cli/azure/install-azure-cli) para instalar a versão mais recente da Azure CLI.
3. **Configurar credenciais do Azure**: Execute `az login` no terminal e siga as instruções para autenticar com suas credenciais do Azure.

## Passo a Passo

1. **Clone este repositório ou crie uma pasta para o seu projeto**:
   ```sh
   git clone <URL_DO_REPOSITORIO>
   cd <NOME_DA_PASTA>
   
2. Crie um arquivo main.tf:
 
Copie o código Terraform fornecido e cole no arquivo main.tf.

3. Crie arquivos adicionais:
 
docker-compose.yml: Contendo a configuração do Docker Compose.
Dockerfile: Contendo as instruções para construir sua imagem Docker.

4. Inicialize o Terraform:

terraform init

5. Revise o plano de execução do Terraform:
   
terraform plan

6. Aplique o plano do Terraform para provisionar a infraestrutura:

terraform apply

Digite yes quando solicitado para confirmar a execução.

7. Acesse a máquina virtual:
   
Após a conclusão, o endereço IP público da VM será exibido como saída. Use este IP para se conectar à VM:

adminuser@<IP_PUBLICO>

#Recursos Criados

.Grupo de Recursos

.Rede Virtual

.Sub-rede

.Endereço IP Público

.Interface de Rede

.Máquina Virtual

.Grupo de Segurança de Rede

.Regras de Segurança de Rede

.Associação de Grupo de Segurança à Interface de Rede

.Extensão de Máquina Virtual para instalação do Docker e Docker Compose

.Provisionamento de arquivos e execução remota

.Limpeza

#Para destruir os recursos criados pelo Terraform, execute:

terraform destroy

Digite "yes" quando solicitado para confirmar a destruição.

