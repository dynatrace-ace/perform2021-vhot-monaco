terraform {

}

provider "dynatrace" {
  dt_cluster_url   = var.dt_cluster_url
  dt_cluster_api_token = var.dt_cluster_api_token
}

provider "google" {
  project = var.gcloud_project
  region  = join("-", slice(split("-", var.gcloud_zone), 0, 2))
  credentials = file(var.gcloud_cred_file)
}

## For creating UUIDs
resource "random_id" "uuid" {
  byte_length = 4
}
