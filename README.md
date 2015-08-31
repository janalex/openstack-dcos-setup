# openstack-dcos-setup
## Deploying Mesosphere DCOS clusters to OpenStack

This repository contains code and instructions for the Terraform module that allows automated deployment of Mesosphere DCOS cluster to OpenStack-based environment, including public clouds exposing OpenStack compatible API.

## Prerequisites

1. Credentials to your OpenStack-based environment
1. Base image for the DCOS cluster nodes with supported DCOS support OS
1. An OpenStack project/tenant to deploy your DCOS cluster to.
1. ID of the public network in your OpenStack tenant - this is where the DCOS network router’s public facing interface will be attached to.
1. [Terraform](http://terraform.io) installed on your machine.

## Steps

1. Clone this repo.
1. Create a new top-level terraform file by copying the example provided (dcos.openstack.tf.example) and filling in your specific information for the appropriate variables.
1. Run `terraform get` from the top-level directory to setup the terraform workspace
1. Execute `terraform apply` from the top-level directory of this repo
1. If everything goes well, the URL of the DCOS dashboard should be reported from the terraform execution.

## License

Licensed under the MIT License.
