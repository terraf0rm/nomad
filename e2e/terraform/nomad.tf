locals {
  # note these configurations aren't the same as the default values of the
  # matching variables, because those variables are a list of lists; these get
  # applied to each node if the variable is set
}

module "nomad_server" {

  depends_on = [aws_instance.server]
  count      = var.server_count

  source = "./install-nomad"

  nomad_version      = var.nomad_version
  nomad_sha          = var.nomad_sha
  nomad_local_binary = var.nomad_local_binary

  config_files = length(var.nomad_server_configs) > count.index ? var.nomad_server_configs[count.index] : var.nomad_default_server_configs

  connection = {
    type        = "ssh"
    user        = "ubuntu"
    host        = "aws_instance.server.${count.index}.public_ip"
    port        = 22
    private_key = module.keys.key_name
  }
}

# TODO: split out the different Linux targets (ubuntu, centos, arm, etc.) when
# they're available
module "nomad_client_linux" {

  depends_on = [aws_instance.client_linux]
  count      = var.client_count

  source = "./install-nomad"

  nomad_version      = var.nomad_version
  nomad_sha          = var.nomad_sha
  nomad_local_binary = var.nomad_local_binary

  config_files = length(var.nomad_client_configs_linux) > count.index ? var.nomad_client_configs_linux[count.index] : var.nomad_default_client_configs_linux

  connection = {
    type        = "ssh"
    user        = "ubuntu"
    host        = "aws_instance.client_linux.${count.index}.public_ip"
    port        = 22
    private_key = module.keys.key_name
  }
}

# TODO: split out the different Windows targets (2016, 2019) when they're
# available
module "nomad_client_windows" {

  depends_on = [aws_instance.client_windows]
  count      = var.windows_client_count

  source = "./install-nomad"

  nomad_version      = var.nomad_version
  nomad_sha          = var.nomad_sha
  nomad_local_binary = var.nomad_local_binary

  config_files = length(var.nomad_client_configs_windows) > count.index ? var.nomad_client_configs_windows[count.index] : var.nomad_default_client_configs_windows

  connection = {
    type        = "ssh"
    user        = "Administrator"
    host        = "aws_instance.client_windows.${count.index}.public_ip"
    port        = 22
    private_key = module.keys.key_name
  }
}
