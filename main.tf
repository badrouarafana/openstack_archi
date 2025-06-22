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
  auth_url    = "http://192.168.56.2/identity"
  region      = "RegionOne"
}


#create network for pki 

resource "openstack_networking_network_v2" "pki_network" {
  name           = var.pki_network_name
  admin_state_up = "true"
}

resource "openstack_networking_subnet_v2" "pki_subnet" {
  name       = var.pki_subnet_name
  network_id = openstack_networking_network_v2.pki_network.id
  cidr       = "10.10.1.0/24"
  dns_nameservers = ["8.8.8.8"]
  ip_version = 4
}

resource "openstack_networking_network_v2" "servers_network" {
  name           = var.servers_network_name
  admin_state_up = "true"
}

resource "openstack_networking_subnet_v2" "servers_subnet" {
  name       = var.servers_subnet_name
  network_id = openstack_networking_network_v2.servers_network.id
  cidr       = "10.10.2.0/24"
  dns_nameservers = ["8.8.8.8"]
  ip_version = 4
}

resource "openstack_networking_router_v2" "router" {
  name                = "router"
  admin_state_up      = true
}

resource "openstack_networking_router_interface_v2" "router_pki_subnet" {
  router_id = openstack_networking_router_v2.router.id
  subnet_id = openstack_networking_subnet_v2.pki_subnet.id
}

resource "openstack_networking_router_interface_v2" "router_servers_subnet" {
  router_id = openstack_networking_router_v2.router.id
  subnet_id = openstack_networking_subnet_v2.servers_subnet.id
}


resource "openstack_networking_secgroup_v2" "default_sec_group" {
  name        = "default_sec_group"
  description = "a security group"
}

resource "openstack_networking_secgroup_rule_v2" "default" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "icmp"
  remote_ip_prefix  = "0.0.0.0/0"
  security_group_id = openstack_networking_secgroup_v2.default_sec_group.id
}

resource "openstack_networking_secgroup_rule_v2" "secgroup_rule_pki_ssh" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 22
  port_range_max    = 22
  remote_ip_prefix  = "0.0.0.0/0"
  security_group_id = openstack_networking_secgroup_v2.default_sec_group.id

}


resource "openstack_compute_instance_v2" "acme_server" {
  name            = var.acme_server
  image_id        = var.ubuntu_image_id
  flavor_id       = var.flavor_m1_small
  key_pair        = var.key_pair
  security_groups = [openstack_networking_secgroup_v2.default_sec_group.name]

  network {
    name = var.pki_network_name
  }
}

resource "openstack_compute_instance_v2" "web_server" {
  name            = var.web_server
  image_id        = var.centos_image_id
  flavor_id       = var.flavor_m1_small
  key_pair        = var.key_pair
  security_groups = [openstack_networking_secgroup_v2.default_sec_group.name]

  network {
    name = "servers_network"
  }
}



#####
#floating ips

# Allocate a floating IP from the external network
resource "openstack_networking_floatingip_v2" "fip" {
  pool = "public"
}

# Wait until instance is created to get the port dynamically
data "openstack_networking_port_v2" "instance_port" {
  device_id  = openstack_compute_instance_v2.acme_server.id
  network_id = openstack_networking_network_v2.pki_network.id
}



# Associate floating IP with instance's port
resource "openstack_networking_floatingip_associate_v2" "fip_assoc" {
  floating_ip = openstack_networking_floatingip_v2.fip.address
  port_id     = data.openstack_networking_port_v2.instance_port.id
}
###""