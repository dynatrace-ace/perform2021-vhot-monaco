variable "acebox_size" {
  description = "Size (machine type) of the ace-box instance"
  default     = "n2-standard-2"
}

variable "acebox_user" {
  description = "Initial user when ace-box is created"
  default     = "ace"
}

variable "acebox_os" {
  description = "Ubuntu version to use"
  default     = "ubuntu-minimal-1804-lts"
}

variable "gcloud_cred_file" {
  description = "Path to GCloud credential file"
}

variable "gcloud_project" {
  description = "Google Cloud Project where resources will be created"
}

variable "gcloud_zone" {
  description = "Google Cloud Zone where resources will be created"
}

variable "instance_count" {
  description = "Number of instances to create"
  default = "1"
}

variable "name_prefix" {
  description = "Prefix to distinguish the instance"
  default = "ace-box-cloud"
}

variable "ssh_keys" {
  description = "Paths to public and private SSH keys for ace-box user"
  default = {
    private = "./key"
    public  = "./key.pub"
  }
}

variable "dynatrace_environments" {
  description = "Dynatrace environments used for installation and configuration"
  type = map(object({
    url = string
    api_token = string
    paas_token = string
  }))
  default = {
    0 = {
        url = "https://env.live.dynatrace.com"
        paas_token = "ENTER_PAAS_TOKEN_HERE"
        api_token = "ENTER_API_TOKEN_HERE"
    },
  }
}