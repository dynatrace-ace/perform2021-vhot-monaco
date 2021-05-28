## acebox requires public IP address
resource "google_compute_address" "acebox" {
  name     = "${var.name_prefix}-${count.index}-ipv4-addr-${random_id.uuid.hex}"
  count = var.instance_count
}

## Allow access to acebox via HTTPS
resource "google_compute_firewall" "acebox-https" {
  name    = "${var.name_prefix}-allow-https-${random_id.uuid.hex}"
  network = "default"

  allow {
    protocol = "tcp"
    ports    = ["443", "16443"]
  }

  target_tags = ["${var.name_prefix}-${random_id.uuid.hex}"]
}

## Allow access to acebox via HTTP
resource "google_compute_firewall" "acebox-http" {
  name    = "${var.name_prefix}-allow-http-${random_id.uuid.hex}"
  network = "default"

  allow {
    protocol = "tcp"
    ports    = ["80"]
  }

  target_tags = ["${var.name_prefix}-${random_id.uuid.hex}"]
}

## Create acebox host
resource "google_compute_instance" "acebox" {
  for_each     = var.dynatrace_environments
  name         = "${var.name_prefix}-${each.key}-${random_id.uuid.hex}"
  machine_type = var.acebox_size
  zone         = var.gcloud_zone

  boot_disk {
    initialize_params {
      image = var.acebox_os
      size  = "40"
    }
  }

  network_interface {
    network = "default"

    access_config {
      nat_ip = "${google_compute_address.acebox[each.key].address}"
    }
  }

  metadata = {
    sshKeys = "${var.acebox_user}:${file(var.ssh_keys["public"])}"
  }

  tags = ["${var.name_prefix}-${random_id.uuid.hex}"]

  connection {
    host        = self.network_interface.0.access_config.0.nat_ip
    type        = "ssh"
    user        = var.acebox_user
    private_key = file(var.ssh_keys["private"])
  }

  provisioner "remote-exec" {
    inline = ["sudo apt-get update && sudo DEBIAN_FRONTEND=noninteractive apt-get upgrade -y"]
  }

  /*provisioner "file" {
    source      = "${path.module}/../microk8s"
    destination = "~/"
  }

  provisioner "file" {
    source      = "${path.module}/../install.sh"
    destination = "~/install.sh"
  }*/

  /*provisioner "remote-exec" {
    inline = [
        "tr -d '\\015' < /home/${var.acebox_user}/install.sh > /home/${var.acebox_user}/install_fixed.sh",
        "chmod +x /home/${var.acebox_user}/install_fixed.sh",
        "/home/${var.acebox_user}/install_fixed.sh ${self.network_interface.0.access_config.0.nat_ip} ${var.acebox_user}"
      ]
  }*/
  provisioner "remote-exec" {
    inline = [
        "sudo sed -i 's/PasswordAuthentication no/PasswordAuthentication yes/' /etc/ssh/sshd_config",
        "sudo service ssh restart",
        #"sudo adduser ${var.acebox_user} --disabled-password --gecos ''",
        #"sudo echo ${var.acebox_user}:${var.acebox_user} | chpasswd",
        "sudo usermod -aG sudo ${var.acebox_user}",
      ]
  }

  provisioner "file" {
    source      = "${path.module}/build-env.sh"
    destination = "~/install.sh"
  }

  provisioner "remote-exec" {
    inline = [
        "sudo export DYNATRACE_ENVIRONMENT_URL=${each.value["url"]}",
        "sudo export DYNATRACE_API_TOKEN=${each.value["api_token"]}",
        "sudo export DYNATRACE_PAAS_TOKEN=${each.value["paas_token"]}",
        "sudo chmod +x ~/install.sh",
        "sudo DYNATRACE_ENVIRONMENT_URL=${each.value["url"]} DYNATRACE_API_TOKEN=${each.value["api_token"]} DYNATRACE_PAAS_TOKEN=${each.value["paas_token"]} ~/install.sh"
      ]
  }
}
