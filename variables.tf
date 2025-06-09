variable "acme_server" {
 default = "acme-server"
}

variable "web_server" {
 default = "web-server"
}


variable "ubuntu_image_id" {
  default = "81d47fb8-8016-4327-bead-c75abb496b0b"
}

variable "centos_image_id" {
  default = "5263a683-8fdd-4aa1-8bb5-9209d9a1b116"
}


variable "flavor_m1_small" {
  default = "2"
}

variable "key_pair" {
  default = "test"
  
}


variable "allowed_tcp_ports" {
  type = list(number)
  default = [22, 80, 443]
  description = "list of allowed TCP ports for security group rules"
}