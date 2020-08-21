locals {
  install_config_script = var.platform == "windows_amd64" ? "C:/opt/install-consul-config.ps1" : "/opt/install-consul-config"
}

resource "null_resource" "upload_configs" {

  for_each = var.config_files
  triggers = {
    contents = filemd5(each.key)
  }

  connection {
    type        = "ssh"
    user        = var.connection.user
    host        = var.connection.host
    port        = var.connection.port
    private_key = var.connection.private_key
  }

  provisioner "file" {
    source      = each.key
    destination = "/tmp/${basename(each.key)}"
  }
}

resource "null_resource" "install_configs" {

  depends_on = [null_resource.upload_configs]

  connection {
    type        = "ssh"
    user        = var.connection.user
    host        = var.connection.host
    port        = var.connection.port
    private_key = var.connection.private_key
  }

  provisioner "remote-exec" {
    inline = [
      #"sudo mv /tmp/install-config ${local.install_config_script}",
      #"${local.install_config_script}",
      # TODO: this is temporary until we bake it into the AMI
      "sudo mkdir -p /etc/consul.d",
      "sudo cp /tmp/*.json /etc/consul.d/",
      "sudo chown -R root:root /etc/consul.d",
      "sudo cp /tmp/consul.service /etc/systemd/system/consul.service",
      "sudo systemctl restart consul",
    ]
  }

}
