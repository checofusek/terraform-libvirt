variable "cant_instances" {
 description = "Cantidad de servidores"
 type = number
 default = 1
}

variable "instance_mem" {
 description = "Cantidad de memoria"
 type = number
 default = 4096
}

variable "instance_cpu" {
 description = "Cantidad de cpu"
 type = number
 default = 2
}

variable "storage_pool" {
 description = "Pool de discos"
 type = string
 default = "/tmp/terraform-provider-libvirt-pool-ubuntu"
}

variable "source_img" {
 description = "Imagen fuente de servidores"
 type = string
 default = "/home/miguel/Downloads/focal-server-cloudimg-amd64-disk-kvm.img"
 #default = https://cloud-images.ubuntu.com/focal/current/focal-server-cloudimg-amd64-disk-kvm.img
}

variable "resource_tags" {
 description = "Tags to set for all resources"
 type        = map(string)
 default     = {
   project     = "servers",
   environment = "dev"
 }
}
