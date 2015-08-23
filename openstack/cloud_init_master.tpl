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
      file:///tmp

  - path: /etc/mesosphere/roles/master

  - path: /etc/mesosphere/setup-packages/dcos-config--setup/pkginfo.json
    content: '{}'

  - path: /etc/mesosphere/setup-packages/dcos-config--setup/etc/mesos-dns.json
    content: |
      {
        "zk": "zk://127.0.0.1:2181/mesos",
        "refreshSeconds": 30,
        "ttl": 60,
        "domain": "mesos",
        "port": 53,
        "resolvers": [ "${dns_fallback}" ],
        "timeout": 5,
        "listener": "0.0.0.0",
        "email": "root.mesos-dns.mesos"
      }
  - path: /etc/mesosphere/setup-packages/dcos-config--setup/etc/mesos-master
    content: |
      MESOS_LOG_DIR=/var/log/mesos
      MESOS_WORK_DIR=/var/lib/mesos/master
      MESOS_ZK=zk://127.0.0.1:2181/mesos
      MESOS_QUORUM=1
      MESOS_CLUSTER=${cluster_name}
      MESOS_ROLES=slave_public
      MESOS_HOSTNAME=dcos-master.novalocal
  - path: /etc/mesosphere/setup-packages/dcos-config--setup/etc/cloudenv
    content: |
      ZOOKEEPER_CLUSTER_SIZE=1
      MASTER_ELB=127.0.0.1
      FALLBACK_DNS=${dns_fallback}
      MARATHON_HOSTNAME=dcos-master.novalocal
  - path: /etc/mesosphere/setup-packages/dcos-config--setup/etc/exhibitor
    content: |
      EXHIBITOR_FSCONFIGDIR=/var/lib/exhibitor-config
      EXHIBITOR_WEB_UI_PORT=8181
