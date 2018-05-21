variable "location" {
  description = "Location for Services"
  type        = "string"
  default     = "West Europe"
}

variable "project_name" {
  description = "projhect Name"
  type        = "string"
  default     = "Project Name"
}

variable "environment" {
  description = "Target Envioronment for Config and Deployment"
  type        = "string"
  default     = "Developmemt"
}

variable "costcode" {
  description = "project CostCode"
  type        = "string"
  default     = "CostCode"
}

variable "contact" {
  description = "Primary Contact for Resource"
  type        = "string"
  default     = "Contact Name"
}

variable "resource_group_name" {
  description = "Resource Group"
  type        = "string"
  default     = "RG-AMS-VCAP-PROD"
}

variable "docker_image_registry" {
  description = "Docker Image Registry"
  type        = "string"
  default     = "dockerregistry"
}



