# Define required providers
terraform {
required_version = ">= 0.14.0"
  required_providers {
    openstack = {
      source  = "terraform-provider-openstack/openstack"
      version = "~> 1.35.0"
    }
  }
}

# Configure the OpenStack Provider
provider "openstack" {
  user_name   = ""
  tenant_name = ""
  tenant_id = ""
  password    = ""
  auth_url    = "https://xxx.xxx.xxx.xxx:xxxx"
  insecure = "true"
}

# Create a web server
resource "openstack_compute_instance_v2" "renancs" {
  count = 1
  name = "vm-ubuntu-jarvis-${count.index + 1}"
  image_name = "ubuntu-20.04.1-server-64bit"
  flavor_name = "m1.large"
  key_pair = "mano-osm"
  security_groups = ["default"]

  user_data = file("./cloud-init.config")
  depends_on = [openstack_networking_subnet_v2.subrede-jarvis]
  network {
    name = "${openstack_networking_network_v2.rede-jarvis.name}"
  }
}

resource "openstack_networking_network_v2" "rede-jarvis" {
	name           = "rede-jarvis"
	admin_state_up = "true"
}

resource "openstack_networking_subnet_v2" "subrede-jarvis" {
  name = "subrede-jarvis"
  network_id = "${openstack_networking_network_v2.rede-jarvis.id}"
  cidr = "192.168.109.0/24"
  gateway_ip = "192.168.109.1"
  ip_version = 4
  allocation_pool {
    start = "192.168.109.100"
    end = "192.168.109.200"
  }
}

resource "openstack_networking_router_v2" "roteador-jarvis" {
	name = "roteador-jarvis"
	external_network_id = "b32ae8ee-391a-4f6d-9307-30eedd6833a8"
}

resource "openstack_networking_router_interface_v2" "router_interface_1" {
	router_id = "${openstack_networking_router_v2.roteador-jarvis.id}"
	subnet_id = "${openstack_networking_subnet_v2.subrede-jarvis.id}"
}