provider "azurerm" {
}
resource "azurerm_resource_group" "myterraformgroup" {
        name = "RG-NiFi"
        location = "eastus"
 
        tags {
                environment = "standalone"
                contact = "username"
    }
}
 
resource "azurerm_virtual_network" "myterraformnetwork" {
    name                = "vnet-nifi"
    address_space       = ["10.0.0.0/16"]
    location            = "eastus"
    resource_group_name = "${azurerm_resource_group.myterraformgroup.name}"
 
    tags {
        environment = "standalone"
        contact = "username"
 
    }
}
 
# Create subnet
resource "azurerm_subnet" "myterraformsubnet" {
    name                 = "subnet-nifi"
    resource_group_name  = "${azurerm_resource_group.myterraformgroup.name}"
    virtual_network_name = "${azurerm_virtual_network.myterraformnetwork.name}"
    address_prefix       = "10.0.1.0/24"
}
 
# Create public IPs
resource "azurerm_public_ip" "myterraformpublicip" {
    name                         = "ip-nifi"
    location                     = "eastus"
    resource_group_name          = "${azurerm_resource_group.myterraformgroup.name}"
    public_ip_address_allocation = "dynamic"
 
    tags {
        environment = "standalone"
        contact = "username"
 
    }
}
 
# Create Network Security Group and rule
resource "azurerm_network_security_group" "myterraformnsg" {
    name                = "nsg-nifi"
    location            = "eastus"
    resource_group_name = "${azurerm_resource_group.myterraformgroup.name}"
 
    security_rule {
        name                       = "SSH"
        priority                   = 1001
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "22"
        source_address_prefix      = "*"
        destination_address_prefix = "*"
    }
 
    tags {
        environment = "standalone"
        contact = "username"
    }
}
 
# Create network interface
resource "azurerm_network_interface" "myterraformnic" {
    name                      = "nic-nifi"
    location                  = "eastus"
    resource_group_name       = "${azurerm_resource_group.myterraformgroup.name}"
    network_security_group_id = "${azurerm_network_security_group.myterraformnsg.id}"
 
    ip_configuration {
        name                          = "myNicConfiguration"
        subnet_id                     = "${azurerm_subnet.myterraformsubnet.id}"
        private_ip_address_allocation = "dynamic"
        public_ip_address_id          = "${azurerm_public_ip.myterraformpublicip.id}"
    }
 
    tags {
        environment = "standalone"
        contact = "username"
    }
}
 
# Generate random text for a unique storage account name
resource "random_id" "randomId" {
    keepers = {
        # Generate a new ID only when a new resource group is defined
        resource_group = "${azurerm_resource_group.myterraformgroup.name}"
    }
 
    byte_length = 8
}
 
# Create storage account for boot diagnostics
resource "azurerm_storage_account" "mystorageaccount" {
    name                        = "diag${random_id.randomId.hex}"
    resource_group_name         = "${azurerm_resource_group.myterraformgroup.name}"
    location                    = "eastus"
    account_tier                = "Standard"
    account_replication_type    = "LRS"
 
    tags {
        environment = "standalone"
        contact = "username"
    }
}
 
# Create virtual machine
resource "azurerm_virtual_machine" "myterraformvm" {
    name                  = "vm-nifi"
    location              = "eastus"
    resource_group_name   = "${azurerm_resource_group.myterraformgroup.name}"
    network_interface_ids = ["${azurerm_network_interface.myterraformnic.id}"]
    vm_size               = "Standard_DS1_v2"
 
    storage_os_disk {
        name              = "myOsDisk"
        caching           = "ReadWrite"
        create_option     = "FromImage"
        managed_disk_type = "Premium_LRS"
    }
 
    storage_image_reference {
        publisher = "Canonical"
        offer     = "UbuntuServer"
        sku       = "16.04.0-LTS"
        version   = "latest"
    }
 
    os_profile {
        computer_name  = "vm-nifi"
        admin_username = "azureuser"
    }
 
    os_profile_linux_config {
        disable_password_authentication = true
        ssh_keys {
            path     = "/home/azureuser/.ssh/authorized_keys"
            key_data = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQC8zku40xkNKrz2T2Swo2gEs6L8Jmp0UlruxH8u55QyPdKiWb7wzpNMsn6uhOkJ77L5+FLFm0CvP28dtCAcQwX0IdHGMv3lNru62EqA5cppv8BqZTlLkArS2Ord9Bmn445j3gVr+9LE2jAoMNNnQ7pHRVHn1iYkm/VSnQPu9IUPyj6uRISxg1efVumYI3Ov8vk2vrIiRWWZVkTTVEGN9RRbS8Q++KOrxmjw0Or4PnOcMbYB9OzsUVK4lmLgpY1/Td7kc2GSMdgglWt+bZr2aH9IMfjxignMdbycTmxjG4eDRvPMAU5e97slIOKyUfAiTLblBr8KHWEG/y5IKhdlXsRL7Bpo3a1EFdNSJs/JfZ9U8B/aLEYGobpUn3F4Gv7udnYodTuBM9H/Eo/LORKdDDGOC43sABUs+vmLVwhS2HQ9kWK8YoIVYVlechVB3Cb7AL7KWnjtKZTYqQAAcheRtOMNP2Wi9KVJewdmrj9W0nCYY5QK4hFfBD1cMRQuSQhQolcoIs6Ssh9+Nt/KiFFRRcz/kIqI89ctrOYMNOASQ6sf2wh1yWuY1aWrLPcGLp1GocLwBI0wvm4AQR/YNyOBMqqyKuA4zshTlCrnUorb8KG5/dgqO/5ikbuduNBRSmR2Hb2o254HMaaGTL3shhJFCrWFzbK7r9XgXuArdJL2kbLFOQ== pknw1@ns515993.ip-167-114-210.net"
        }
    }
 
    boot_diagnostics {
        enabled = "true"
        storage_uri = "${azurerm_storage_account.mystorageaccount.primary_blob_endpoint}"
    }
 
    tags {
        environment = "standalone"
        contact = "username"
    }
}
