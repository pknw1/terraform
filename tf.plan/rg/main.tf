provider "azurerm" {
}

resource "azurerm_resource_group" "myRG" {
    name     = "${var.resource_group_name}-test"
    location = "${var.location}"

}
