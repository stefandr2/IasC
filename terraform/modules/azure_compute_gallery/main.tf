resource "azurerm_resource_group" "rg" {
  name     = var.resource_group_name
  location = var.location
  tags     = var.tags
}

resource "azurerm_shared_image_gallery" "gallery" {
  name                = "sig${var.name_prefix}${var.environment}"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  description         = "Golden image gallery for Arc operations baseline"
  tags                = var.tags
}

resource "azurerm_shared_image" "windows2022" {
  name                = "win2022"
  gallery_name        = azurerm_shared_image_gallery.gallery.name
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  os_type             = "Windows"

  identifier {
    publisher = "Contoso"
    offer     = "WindowsServer"
    sku       = "2022"
  }

  tags = var.tags
}
