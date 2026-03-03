aks_rg_name="aks-rg"
location = "South India"

aks_vnet_name = "aks_vnet"
aks_vnet_cidr = ["10.0.0.0/16"] #TODO 10.0.0.0/16

aks_public_subnet_name = "aks_public_subnet"
aks_private_subnet_name = "aks_private_subnet"

aks_public_subnet_cidr =  ["10.0.1.0/24"]
aks_private_subnet_cidr = ["10.0.3.0/24"]

azp_token      = "CMcH7HBDhlNrYnssnUOpNI7shKOtJXQrveq8i7UqHgy6Dvu8bJ2WJQQJ99CBACAAAAAAAAAAAAASAZDO4DYg"
azp_url        = "https://dev.azure.com/sreenivasad0208"
azp_pool       = "self-hosted"
azp_agent_name = "self-hosted-pipeline"


