variable "acme_server" {
 default = "acme-server"
}

variable "web_server" {
 default = "web-server"
}


variable "ubuntu_image_id" {
  default = "4b1824e4-9805-4aec-86d6-c48ac7372910"
}

variable "centos_image_id" {
  default = "3db25435-376b-4ceb-81ca-03d4c48e21d7"
}


variable "flavor_m1_small" {
  default = "2"
}

variable "key_pair" {
  default = "test"
  
}


variable "pki_network_name" {
  default = "pki_network"
  
}
variable "pki_subnet_name" {
  default = "pki_subnet"
  
}
variable "servers_subnet_name" {
  default = "servers_subnet"
  
}


variable "servers_network_name" {
  default = "servers_network"
  
}


variable "allowed_tcp_ports" {
  type = list(number)
  default = [22, 80, 443]
  description = "list of allowed TCP ports for security group rules"
}