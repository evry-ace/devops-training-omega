variable "prefix" {
  default = "aks"
}

variable "sp_client_id" {
  description = "The Client ID for the Service Principal to use for this Managed Kubernetes Cluster"
  type = string
}

variable "sp_client_secret" {
  description = "The Client Secret for the Service Principal to use for this Managed Kubernetes Cluster"
  type = string
}

variable "tenant_id" {
  type = string
}

variable "subscription_id" {
  type = string
}

variable "client_id" {
  type = string
}

variable "client_secret" {
  type = string
}
