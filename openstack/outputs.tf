output "dcos_target" {
	value = "http://${openstack_compute_instance_v2.dcos-master.floating_ip}/"
}
