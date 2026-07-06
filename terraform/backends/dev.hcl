resource_group_name  = "rg-arcops-tfstate-dev"
storage_account_name = "starcopstfdev"
container_name       = "tfstate"
key                  = "arcops/dev/terraform.tfstate"
use_oidc             = true
use_azuread_auth     = true
