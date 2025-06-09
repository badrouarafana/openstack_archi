terraform {
  required_version = ">= 0.14.0"
  required_providers {
    openstack = {
      source  = "terraform-provider-openstack/openstack"
      version = "~> 1.53.0"
    }
  }
}

provider "openstack" {
  user_name   = "demo"
  tenant_name = "demo"
  password    = "password"
  auth_url    = "http://192.168.1.195/identity"
  region      = "RegionOne"
}












# Security group
resource "openstack_networking_secgroup_v2" "web_server_sg" {
  name        = "web_server_sg"
  description = "My neutron security group"
}

resource "openstack_networking_secgroup_rule_v2" "secgroup_rules" {
  for_each = { for port in var.allowed_tcp_ports : tostring(port) => port }

  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = each.value
  port_range_max    = each.value
  remote_ip_prefix  = "0.0.0.0/0"
  security_group_id = openstack_networking_secgroup_v2.web_server_sg.id
}

# Instance
resource "openstack_compute_instance_v2" "acme_server" {
  name            = var.acme_server
  image_id        = var.ubuntu_image_id
  flavor_id       = var.flavor_m1_small
  key_pair        = var.key_pair
  security_groups = [openstack_networking_secgroup_v2.web_server_sg.name]

  network {
    name = "private"
  }
}


resource "openstack_compute_instance_v2" "web_server" {
  name            = var.web_server
  image_id        = var.centos_image_id
  flavor_id       = var.flavor_m1_small
  key_pair        = var.key_pair
  security_groups = [openstack_networking_secgroup_v2.web_server_sg.name]

  network {
    name = "private"
  }
}





# # Allocate a floating IP from the external network
# resource "openstack_networking_floatingip_v2" "fip" {
#   pool = "public"
# }

# # Wait until instance is created to get the port dynamically
# data "openstack_networking_port_v2" "instance_port" {
#   device_id  = openstack_compute_instance_v2.acme_server" {.id
#   network_id = data.openstack_networking_network_v2.private.id
# }

# # Get private network ID by name
# data "openstack_networking_network_v2" "private" {
#   name = "private"
# }

# # Associate floating IP with instance's port
# resource "openstack_networking_floatingip_associate_v2" "fip_assoc" {
#   floating_ip = openstack_networking_floatingip_v2.fip.address
#   port_id     = data.openstack_networking_port_v2.instance_port.id
# }
