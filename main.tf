provider "azurerm" {
}

resource "azurerm_resource_group" "my_azurerm_resource_group" {
    name     = "${var.resource_group_name}"
    location = "${var.location}"
}

data "azurerm_client_config" "current" {}

resource "random_id" "server" {
  keepers = {
    ami_id = 1
  }
  byte_length = 8
}

resource "azurerm_key_vault" "tmpvar" {
  name                = "${format("%s%s", "kv", random_id.server.hex)}"
  location            = "${var.location}"
  resource_group_name = "${var.resource_group_name}"
  tenant_id           = "${data.azurerm_client_config.current.tenant_id}"

  sku {
    name = "premium"
  }

  access_policy {
    tenant_id = "${data.azurerm_client_config.current.tenant_id}"
    object_id = "aa4258da-1f5a-4595-8ffd-6588461d65b8"

    key_permissions = [
      "get",
    ]

    secret_permissions = [
      "get",
    ]
  }

  tags {
    project   = "${var.project_name}"
    environment = "${var.environment}"
    costcode  = "${var.costcode}"
  }
}


resource "azurerm_storage_account" "test" {
  name                     = "${format("%s%s", "stor", random_id.server.hex)}"
  resource_group_name      = "${var.resource_group_name}"
  location                 = "${var.location}"
  account_tier             = "Standard"
  account_replication_type = "GRS"

}

resource "azurerm_container_registry" "test" {
  name                = "${format("%s%s", "reg", random_id.server.hex)}"
  resource_group_name      = "${var.resource_group_name}"
  location                 = "${var.location}"
  admin_enabled       = true
  sku                 = "Classic"
  storage_account_id  = "${azurerm_storage_account.test.id}"

 }

#resource "azurerm_automation_account" "example" {
#  name                = "automationAccount2"
#  location            = "${var.location}"
#  resource_group_name = "${var.resource_group_name}"
#
#  sku {
#    name = "Basic"
#  }
#
#}

# resource "azurerm_automation_credential" "example" {
#  name                = "credential1"
#  resource_group_name = "${var.resource_group_name}"
#  account_name        = "${azurerm_automation_account.example.name}"
#  username           = "example_user"
#  password            = "example_pwd"
#  description         = "This is an example credential"
#}
