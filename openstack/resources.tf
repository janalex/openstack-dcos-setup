resource "openstack_compute_keypair_v2" "dcos-key" {
	name = "${var.openstack_key_name}"
	region = "${var.openstack_region}"
	public_key = "${var.openstack_public_key}"
}

resource "openstack_compute_secgroup_v2" "dcos-sg" {
    region = "${var.openstack_region}"
    name = "dcos-sg"
    description = "Security Group for DCOS cluster"
    # rule {
    #     from_port = 22
    #     to_port = 22
    #     ip_protocol = "tcp"
    #     cidr = "0.0.0.0/0"
    # }
    rule {
        from_port = 1
        to_port = 65535
        ip_protocol = "tcp"
        cidr = "0.0.0.0/0"
    }
    rule {
        from_port = 1
        to_port = 65535
        ip_protocol = "udp"
        cidr = "0.0.0.0/0"
    }
    rule {
    	from_port = -1
    	to_port = -1
    	ip_protocol = "icmp"
    	cidr = "0.0.0.0/0"
    }
    rule {
        from_port = 1
        to_port = 65535
        ip_protocol = "tcp"
        self = true
    }
    rule {
        from_port = 1
        to_port = 65535
        ip_protocol = "udp"
        self = true
    }
    rule {
        from_port = -1
        to_port = -1
        ip_protocol = "icmp"
        self = true
    }
}

resource "openstack_networking_network_v2" "dcos-network" {
	region = "${var.openstack_region}"
	name = "dcos-network"
	admin_state_up = "true"
}

resource "openstack_networking_subnet_v2" "dcos-subnet" {
	region = "${var.openstack_region}"
	network_id = "${openstack_networking_network_v2.dcos-network.id}"
	cidr = "${var.openstack_subnet_cidr_block}"
	ip_version = 4
}

resource "openstack_networking_router_v2" "dcos-router" {
    region = "${var.openstack_region}"
    name = "dcos-router"
    admin_state_up = "true"
    external_gateway = "${var.openstack_neutron_router_gateway_network_id}"
}

resource "openstack_networking_router_interface_v2" "dcos-router-interface" {
    region = "${var.openstack_region}"
    router_id = "${openstack_networking_router_v2.dcos-router.id}"
    subnet_id = "${openstack_networking_subnet_v2.dcos-subnet.id}"
}

resource "openstack_compute_floatingip_v2" "master-fip" {
    region = "${var.openstack_region}"
    pool = "${var.openstack_floating_ip_pool_name}"
}

resource "template_file" "cloud-init-master" {
	filename = "${path.module}/cloud_init_master.tpl"

	vars {
		dns_fallback = "${var.dns_fallback}"
		cluster_name = "${var.dcos_cluster_name}"
	}
}

resource "openstack_compute_instance_v2" "dcos-master" {
	depends_on = [
		"openstack_networking_router_interface_v2.dcos-router-interface",
	]

	region = "${var.openstack_region}"
	name = "dcos-master"
	image_name = "${var.openstack_image}"
	flavor_name = "${var.openstack_instance_type_master}"
	key_pair = "${var.openstack_key_name}"
	security_groups = [ "${openstack_compute_secgroup_v2.dcos-sg.id}" ]
	network {
		uuid = "${openstack_networking_network_v2.dcos-network.id}"
	}
	floating_ip = "${openstack_compute_floatingip_v2.master-fip.address}"

	user_data = "${template_file.cloud-init-master.rendered}"

	connection {
		user = "${var.openstack_ssh_user}"
		key_file = "${var.openstack_ssh_private_key_file}"
		agent = false
	}

	provisioner "remote-exec" {
		inline = [
			"sudo /bin/bash -c 'echo \"${self.network.0.fixed_ip_v4} dcos-master dcos-master.novalocal\" > /etc/hosts'",
			"sudo /bin/bash -c 'echo \"COREOS_PRIVATE_IPV4=${self.network.0.fixed_ip_v4}\" > /etc/environment'",
			"sudo /bin/bash -c 'echo \"COREOS_PUBLIC_IPV4=${self.floating_ip}\" >> /etc/environment'",
			"sudo /bin/bash -c 'echo \"EXHIBITOR_HOSTNAME=${self.network.0.fixed_ip_v4}\" >> /etc/mesosphere/setup-packages/dcos-config--setup/etc/exhibitor'",
		]
	}

	provisioner "local-exec" {
		command = "LOCAL_DCOS_TAR_PATH=${var.local_dcos_tar_path} DCOS_DOWNLOAD_URL=${var.dcos_download_url} ${path.module}/../scripts/local/download_dcos.sh"
	}

	provisioner "remote-exec" {
		inline = [
			"mkdir -p /tmp/config",
		]
	}

	provisioner "file" {
		source = "${var.local_dcos_active_json_path}"
		destination = "/tmp/config/active.json"
	}

	provisioner "file" {
		source = "${var.local_dcos_tar_path}"
		destination = "/tmp/bootstrap.tar.xz"
	}

	provisioner "remote-exec" {
		inline = [
			"sudo mkdir -p /opt/mesosphere",
			"sudo mkdir -p /var/lib/exhibitor-config",
			"sudo /usr/bin/tar -xf /tmp/bootstrap.tar.xz -C /opt/mesosphere",
			"sudo /bin/bash -c \"source /opt/mesosphere/environment.export && /opt/mesosphere/bin/pkgpanda setup\"",
		]
	}
}

resource "template_file" "cloud-init-slave" {
	filename = "${path.module}/cloud_init_slave.tpl"

	vars {
		dns_fallback = "${var.dns_fallback}"
	}
}

resource "openstack_compute_instance_v2" "dcos-slave" {
	depends_on = [
		"openstack_compute_instance_v2.dcos-master",
	]

	count = "${var.num_slaves}"

	region = "${var.openstack_region}"
	name = "dcos-slave-${count.index}"
	image_name = "${var.openstack_image}"
	flavor_name = "${var.openstack_instance_type_slave}"
	key_pair = "${var.openstack_key_name}"
	security_groups = [ "${openstack_compute_secgroup_v2.dcos-sg.id}" ]
	network {
		uuid = "${openstack_networking_network_v2.dcos-network.id}"
	}

	user_data = "${template_file.cloud-init-slave.rendered}"

	connection {
		user = "${var.openstack_ssh_user}"
		key_file = "${var.openstack_ssh_private_key_file}"
		bastion_host = "${openstack_compute_instance_v2.dcos-master.floating_ip}"
		bastion_user = "${var.openstack_ssh_user}"
		bastion_key_file = "${var.openstack_ssh_private_key_file}"
		agent = false
	}

	provisioner "remote-exec" {
		inline = [
			"sudo /bin/bash -c 'echo \"${self.network.0.fixed_ip_v4} ${self.name} ${self.name}.novalocal\" > /etc/hosts'",
			"sudo /bin/bash -c 'echo \"COREOS_PRIVATE_IPV4=${self.network.0.fixed_ip_v4}\" > /etc/environment'",
			"sudo /bin/bash -c 'echo \"MESOS_HOSTNAME=${self.network.0.fixed_ip_v4}\" >> /etc/mesosphere/setup-packages/dcos-config--setup/etc/mesos-slave'",
			"sudo /bin/bash -c 'echo \"MASTER_ELB=${openstack_compute_instance_v2.dcos-master.network.0.fixed_ip_v4}\" >> /etc/mesosphere/setup-packages/dcos-config--setup/etc/cloudenv'",
		]
	}

	provisioner "remote-exec" {
		inline = [
			"mkdir -p /tmp/config",
		]
	}

	provisioner "file" {
		source = "${var.local_dcos_active_json_path}"
		destination = "/tmp/config/active.json"
	}

	provisioner "file" {
		source = "${var.local_dcos_tar_path}"
		destination = "/tmp/bootstrap.tar.xz"
	}

	provisioner "remote-exec" {
		inline = [
			"sudo mkdir -p /opt/mesosphere",
			"sudo /usr/bin/tar -xf /tmp/bootstrap.tar.xz -C /opt/mesosphere",
			"sudo /bin/bash -c \"source /opt/mesosphere/environment.export && /opt/mesosphere/bin/pkgpanda setup\"",
		]
	}
}
