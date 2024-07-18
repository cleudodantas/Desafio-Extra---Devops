# Configura o provedor Azure Resource Manager (azurerm)
provider "azurerm" {
  features {}
}

# Cria um grupo de recursos chamado 'myResourceGroup2' na localizacao 'West US 2'
resource "azurerm_resource_group" "rg" {
  name     = "myResourceGroup2"
  location = "West US 2"
}

# Cria uma rede virtual chamada 'myVnet' com o espaco de endereco '10.0.0.0/16'
resource "azurerm_virtual_network" "vnet" {
  name                = "myVnet"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
}

# Cria uma sub-rede chamada 'mySubnet' com o prefixo de endereco '10.0.1.0/24'
resource "azurerm_subnet" "subnet" {
  name                 = "mySubnet"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.1.0/24"]
}
# Cria um endereco IP publico chamado 'myPublicIP' com alocacao dinamica
resource "azurerm_public_ip" "pip" {
  name                = "myPublicIP"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  allocation_method   = "Dynamic"
}

# Cria uma interface de rede chamada 'myNic' e configura uma IP dinamica tanto para o IP privado quanto para o publico
resource "azurerm_network_interface" "nic" {
  name                = "myNic"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.pip.id
  }
}

# Cria uma maquina virtual chamada 'myVM' com uma interface de rede, especifica o tamanho da VM, define a imagem do sistema operacional (Ubuntu 22.04 LTS), configura o disco do sistema operacional e define as credenciais de administrador
resource "azurerm_virtual_machine" "vm" {
  name                  = "myVM"
  location              = azurerm_resource_group.rg.location
  resource_group_name   = azurerm_resource_group.rg.name
  network_interface_ids = [azurerm_network_interface.nic.id]
  vm_size               = "Standard_B2s"

  storage_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts-gen2"
    version   = "latest"
  }

  storage_os_disk {
    name              = "myOsDisk"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }

  os_profile {
    computer_name  = "myVM"
    admin_username = "adminuser"
    admin_password = "AdminPassword123!"
  }

  os_profile_linux_config {
    disable_password_authentication = false
  }

  tags = {
    environment = "Terraform"
  }
}

# Cria um grupo de seguranca de rede chamado 'myNSG'
resource "azurerm_network_security_group" "nsg" {
  name                = "myNSG"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
}

# Cria uma regra de seguranca para permitir trafego HTTP (porta 80) de entrada
resource "azurerm_network_security_rule" "http" {
  name                        = "HTTP"
  priority                    = 1001
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "80"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.rg.name
  network_security_group_name = azurerm_network_security_group.nsg.name
}

# Cria uma regra de seguranca para permitir trafego SSH (porta 22) de entrada
resource "azurerm_network_security_rule" "ssh" {
  name                        = "SSH"
  priority                    = 1000
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "22"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.rg.name
  network_security_group_name = azurerm_network_security_group.nsg.name
}

# Associa o grupo de seguranca 'myNSG' a interface de rede 'myNic'
resource "azurerm_network_interface_security_group_association" "nicsga" {
  network_interface_id      = azurerm_network_interface.nic.id
  network_security_group_id = azurerm_network_security_group.nsg.id
}

# Adiciona uma extensao a maquina virtual para instalar Docker e Docker Compose
resource "azurerm_virtual_machine_extension" "vm_extension" {
  name                 = "installDocker"
  virtual_machine_id   = azurerm_virtual_machine.vm.id
  publisher            = "Microsoft.Azure.Extensions"
  type                 = "CustomScript"
  type_handler_version = "2.0"

  settings = <<SETTINGS
    {
      "commandToExecute": "sudo apt-get update && sudo apt-get install -y docker.io && sudo systemctl start docker && sudo systemctl enable docker && sudo apt-get install -y docker-compose"
    }
  SETTINGS
}

# Copia arquivos 'docker-compose.yml' e 'Dockerfile' para a maquina virtual e executa comandos para configurar um ambiente WordPress usando Docker
resource "null_resource" "docker_compose" {
  depends_on = [azurerm_virtual_machine.vm]

  provisioner "file" {
    source      = "docker-compose.yml"
    destination = "/home/adminuser/docker-compose.yml"

    connection {
      type     = "ssh"
      user     = "adminuser"
      password = "AdminPassword123!"
      host     = azurerm_public_ip.pip.ip_address
    }
  }

  provisioner "file" {
    source      = "Dockerfile"
    destination = "/home/adminuser/Dockerfile"

    connection {
      type     = "ssh"
      user     = "adminuser"
      password = "AdminPassword123!"
      host     = azurerm_public_ip.pip.ip_address
    }
  }

  provisioner "remote-exec" {
    connection {
      type     = "ssh"
      user     = "adminuser"
      password = "AdminPassword123!"
      host     = azurerm_public_ip.pip.ip_address
    }

    inline = [
      "sudo mkdir -p /srv/wordpress",
      "sudo mv /home/adminuser/docker-compose.yml /srv/wordpress/",
      "sudo mv /home/adminuser/Dockerfile /srv/wordpress/",
      "cd /srv/wordpress && sudo docker-compose up -d"
    ]
  }
}

# Exibe o endereco IP publico da maquina virtual
output "public_ip" {
  value = azurerm_public_ip.pip.ip_address
}
