variable "openstack_access_key" {
    description = "Openstack username"
}

variable "openstack_secret_key" {
    description = "Openstack Password"
}

variable "openstack_tenant_name" {
    description = "Openstack project / tenant name"
}

variable "openstack_keystone_uri" {
    description = "Openstack Keystone API URL"
}

variable "openstack_region" {
    description = "Openstack region"
    default = ""
}

variable "openstack_key_name" {
    description = "The SSH key name to use for the instances."
}

variable "openstack_public_key" {
    description = "The SSH public key to upload as openstack_key_name."
}

variable "openstack_ssh_private_key_file" {
    description = "Path to the SSH private key file."
}

variable "openstack_ssh_user" {
    description = "SSH user."
    default = "ubuntu"
}

variable "openstack_subnet_cidr_block" {
    description = "The IPv4 address range that machines in the network are assigned to, represented as a CIDR block."
    default = "10.0.1.0/24"
}

variable "openstack_subnet_ip_prefix" {
    description = "Subnet IP address prefix"
    default = "10.0.1"
}

variable "openstack_subnet_master_ip_suffix" {
    description = "DCOS Master node ip address within the subnet prefix"
    default = "10"
}

variable "openstack_neutron_router_gateway_network_id" {
    description = "The UUID of the network that will be used as WAN breakout for the neutron L3 Router"
}

variable "openstack_floating_ip_pool_name" {
    description = "The name of the IP pool that floating IP's will be requested from."
}

variable "openstack_image" {
    description = "The name of the image to base the launched instances."
}

variable "openstack_instance_type_master" {
    description = "The machine type to use for the Mesos master instance."
    default = "m3.medium"
}

variable "openstack_instance_type_slave" {
    description = "The machine type to use for the Mesos slave instances."
    default = "m3.medium"
}

variable "num_slaves" {
    description = "The number of Mesos slaves to launch."
    default = "3"
}

variable "dns_fallback" {
    description = "Default DNS fallback server for the DCOS cluster"
    default = "8.8.8.8"
}

variable "dcos_cluster_name" {
    description = "Name of the DCOS Mesos cluster"
    default = "DCOS"
}

variable "dcos_download_url" {
    description = "URL where to download DCOS distribution from"
    default = ""
}

variable "dcos_repository_url" {
    description = "DCOS repository base URL"
    default = ""
}

variable "local_dcos_tar_path" {
    description = "Path to the DCOS bootstrap tar, to deploy to your cluster. If not provided, then by default, the provisioner will download the latest DCOS tar to a .dcos directory within your module path"
    default=".dcos/bootstrap.tar.xz"
}

variable "local_dcos_active_json_path" {
    description = "Path to the DCOS bootstrap active.json, to deploy to your cluster. If not provided, then by default, the provisioner will download the latest DCOS tar to a .dcos directory within your module path"
    default=".dcos/active.json"
}
