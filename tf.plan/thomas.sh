mkdir pydev 
cat > /pydev/pydev.tf <<EOF
provider "azurerm" {
}
resource "azurerm_resource_group" "myterraformgroup" {
        name = "RG-VCAP-DEV"
        location = "eastus"
        tags {
                environment = "development"
                costcode = "cavm"
                contact = "Thomas Masters"
    }
}
resource "azurerm_virtual_network" "myterraformnetwork" {
    name                = "vnet-vcap-dev"
    address_space       = ["10.0.0.0/16"]
    location            = "eastus"
    resource_group_name = "${azurerm_resource_group.myterraformgroup.name}"
    tags {
                environment = "development"
                costcode = "cavm"
                contact = "Thomas Masters"
    }
}
# Create subnet
resource "azurerm_subnet" "myterraformsubnet" {
    name                 = "subnet-vcap-pydev"
    resource_group_name  = "${azurerm_resource_group.myterraformgroup.name}"
    virtual_network_name = "${azurerm_virtual_network.myterraformnetwork.name}"
    address_prefix       = "10.0.1.0/24"
}
# Create public IPs
resource "azurerm_public_ip" "myterraformpublicip" {
    name                         = "ip-vcap-pydev"
    location                     = "eastus"
    resource_group_name          = "${azurerm_resource_group.myterraformgroup.name}"
    public_ip_address_allocation = "dynamic"
    tags {
        environment = "development"
        costcode = "cavm"
        contact = "Thomas Masters"
    }
}
# Create Network Security Group and rule
resource "azurerm_network_security_group" "myterraformnsg" {
    name                = "nsg-vcap-pydev"
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
        environment = "development"
        costcode = "cavm"
        contact = "Thomas Masters"
    }
}
# Create network interface
resource "azurerm_network_interface" "myterraformnic" {
    name                      = "nic-vcap-pydev"
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
        environment = "development"
        costcode = "cavm"
        contact = "Thomas Masters"
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
        environment = "development"
        costcode = "cavm"
        contact = "Thomas Masters"
    }
}
# Create virtual machine
resource "azurerm_virtual_machine" "myterraformvm" {
    name                  = "vm-vcap-pydev"
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
        computer_name  = "vm-vcap-pydev"
        admin_username = "azureuser"
    }
    os_profile_linux_config {
        disable_password_authentication = true
        ssh_keys {
            path     = "/home/azureuser/.ssh/authorized_keys"
            key_data = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDQKC3tbN9XB5NwPIz8KfTB8FJeoJ/2KWOhsPJruTtTXNeeRtovJFZ0aGjYWgoGl5a273Or+FqeBtjxx06ChkNStYNYrTQSrLB/eYjqGJdKu+78VhDpZFbDp0WGV7ozKpE67QF0aQEOTbn/fvihthSuQQAGk4QBNFsOllpBJBU6H3O0wYu62TV8QZY5EM5U3k1eWFG00lZmZl6hhDTIKIuIaoqnEw0H3wqBwwmwHUH75rln3PTStETO/WrvBujQCECNKoeAHJ3N7pZ1gsjbnFLi4BKJH7SavQBC9KuBDueSn7DJqsjd9OfxMBlFi6jgepTBNbGSEtO+B4M3hEiLbvisHZVcGV+PvNxMcKjPDby6P8Qj9SYHsnQ8QSCP2w3kge0OGSKmgWDUfOYvCgZ/rxbWRoRWOqBL9DFy1JkOJtAYwA0ODJ9Xr6xs/b1ndPOjjsiF8/rigqT1LOHu8ns/N8px1v8u2bPSsvMcb8s/RHfNMwnfFPKCHiMTXLnApZYLh4Z5+ODhaFS12AxZr3gkpM2XP7oiaoPdn1jktyRI1xcWdbPFFGey+oysjxV0ACXcOBr2D/PxG4sieO0aCfHnfLf3GB48+1KT/U6fQzDNWbMl4590q5U4Hwq0BJxhXd5XjvDU0qCwIpOXGIdMz7Nq8vy1SDBY9kmdggolmMn5+V2sfw== ca_paul@cc-def6-cb9cc408-1574648948-21cjw"
        }
    }
    boot_diagnostics {
        enabled = "true"
        storage_uri = "${azurerm_storage_account.mystorageaccount.primary_blob_endpoint}"
    }
    tags {
                environment = "development"
                costcode = "cavm"
                contact = "Thomas Masters"
        }
}
EOF

cd pydev
terraform init
terraform plan
terraform apply



