# output "acebox_ip" {
#   #value = "connect using ssh -i key ${var.acebox_user}@${google_compute_instance.acebox.network_interface[0].access_config[0].nat_ip}"
#   value = {
#     for instance in 
#   }
# }
output "dashboard_url" {
  value = {
    for instance in google_compute_instance.acebox: 
    instance.id => "http://dashboard.${instance.network_interface[0].access_config[0].nat_ip}.nip.io"
  }
}

# output "dynatrace_environments" {
#   value = {
#     for env in var.dynatrace_environments: 
#     env.value["env"] => env.value["env"]
#   }
# }

# output "dynatrace_api_tokens" {
#   value = {
#     for env in var.dynatrace_environments: 
#     env.id => env.value["api_token"]
#   }
# }

# output "dynatrace_paas_tokens" {
#   value = {
#     for env in var.dynatrace_environments: 
#     env.id => env.value["paas_token"]
#   }
# }