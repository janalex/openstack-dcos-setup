#cloud-config

coreos:
  update:
    reboot-strategy: off
  units:
    - name: systemd-resolved.service
      command: stop
    - name: etcd.service
      mask: true
      command: stop
    - name: update-engine.service
      mask: true
      command: stop
    - name: locksmithd.service
      mask: true
      command: stop

write_files:
  - path: /etc/mesosphere/setup-flags/repository-url
    permissions: 0644
    owner: root
    content: |
      ${repository_url}

  - path: /etc/mesosphere/roles/slave

  - path: /etc/mesosphere/setup-packages/dcos-config--setup/pkginfo.json
    content: '{}'

  - path: /etc/mesosphere/setup-packages/dcos-config--setup/etc/mesos-slave
    content: |
      MESOS_MASTER=zk://leader.mesos:2181/mesos
      MESOS_CONTAINERIZERS=docker,mesos
      MESOS_LOG_DIR=/var/log/mesos
      MESOS_EXECUTOR_REGISTRATION=5mins
      MESOS_ISOLATION=cgroups/cpu,cgroups/mem
      MESOS_WORK_DIR=/var/lib/mesos/slave
      MESOS_RESOURCES=ports:[1025-2180,2182-3887,3889-5049,5052-8079,8082-8180,8182-65535]
      MESOS_SLAVE_SUBSYSTEMS=cpu,memory

  - path: /etc/mesosphere/setup-packages/dcos-config--setup/etc/cloudenv
    content: |
      ZOOKEEPER_CLUSTER_SIZE=1
      FALLBACK_DNS=${dns_fallback}
