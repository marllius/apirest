# **ApiRest using phyton**

[![apirest - apirest](https://img.shields.io/static/v1?label=apirest&message=apirest&color=purple&logo=github)](https://github.com/marllius/apirest "Go to GitHub repo")
[![stars](https://img.shields.io/badge/Stars-0-purple?logo=github)](https://github.com/marllius/apirest/stargazers)
[![fork](https://img.shields.io/badge/Forks-0-purple?logo=github)](https://github.com/marllius/apirest/network/members)
[![terraform](https://img.shields.io/badge/Terraform_version_>=-1.0.0-purple?logo=terraform)](https://github.com/getzoop/tf-module-db-redis/network/members)
[![ansible](https://img.shields.io/badge/Ansible_version_>=-2.12.2-purple?logo=ansible)](https://github.com/getzoop/tf-module-db-redis/network/members)

# The concept this deploy:

![PostgreSQL Cluster HA](High-availability-diagram.jpg?raw=true "PostgreSQL Cluster HA")

In this configuration, you will deploy at least 13 hosts, 1 host of each type in 1 different Availability Zone:

- 3 pg nodes 
- 3 etcd nodes
- 3 HAProxy nodes
- 3 applications nodes
- 1 pgbackrest repository
- 2 Simple Storage Service (S3 buckets) with cross region replication for DR

# How to use this repository

### Configuring on AWS arquiteture

- Under subdirectory infrastructure you will found the following directories:

```
 .
├──  infraestructure
│  ├──  application.tf
│  ├──  data.tf
│  ├──  environments
│  │  └──  envs.tfvars
│  ├──  etcd_cluster.tf
│  ├──  haproxy_keepalive.tf
│  ├──  iam.tf
│  ├──  kms.tf
│  ├──  postgresql_cluster.tf
│  ├──  provider.tf
│  ├──  s3.tf
│  ├──  security-group.tf
│  ├──  ssh_key.tf
│  ├──  variables.tf
│  └──  vpc.tf
└──  README.md
```
> Terraform [installation guide](https://learn.hashicorp.com/tutorials/terraform/install-cli)

The environment directory has the variables that you want to modify. You can create more files in order to separate the production deployment from development.

for more information about what is each variable on `variables.tf` has a description


- Create the infaestructure on AWS cloud with terraform using env.tfvars

```bash
export AWS_ACCESS_KEY_ID="{YOU-KEY}"
export AWS_SECRET_ACCESS_KEY="{YOUR-SECRET-KEY}"
export AWS_SESSION_TOKEN="{WITH-USE-MFA}" # if necessary

terraform init
terraform plan -var-file=enviroments/env.tfvars
terraform apply -var-file=enviroments/env.tfvars
```

- Create the infaestructure on AWS cloud with terraform using only values on `variables.tf`

```bash
cd apirest/infraestructure
export AWS_ACCESS_KEY_ID="{YOU-KEY}"
export AWS_SECRET_ACCESS_KEY="{YOUR-SECRET-KEY}"
export AWS_SESSION_TOKEN="{WITH-USE-MFA}" # if necessary

terraform init
terraform plan
terraform apply
```
---

## After launching the instances, you will need to configure and install the tools. For that you must run ansible.
---
### **Note: You can use ansible on your local machines if you want.**
> Ansible [installation guide](https://docs.ansible.com/ansible/latest/installation_guide/index.html)


## Usage

- on directory configuration you will found the following files:

```bash

 .
├──  configuration
│  ├──  ansible.cfg
│  ├──  balancers.yml
│  ├──  deploy_app.yml
│  ├──  deploy_pgcluster.yml
│  ├──  deploy_all.yml
│  ├──  etcd_cluster.yml
│  ├──  files
│  │  ├──  api.sql
│  │  ├──  requirements.txt
│  ├──  group_vars
│  ├──  inventory
│  │  └──  environment.ini
│  ├──  roles
│  └──  vars
│     ├──  main.yml
│     └──  system.yml
└──  README.md

```
# Requirements

This playbook requires root privileges or sudo.

1) The files `main.yml` has the configuration variables, you need to change at least this variables:

- postgresql_master  
> ip or dns of pg master machine
- cluster_vip
> ip that keepalive will reponse
- pgbackrest_repo_host
> ip or dns off pgbacrest repository

<br >

2) Edit the inventory file

Specify the ip addresses and connection settings (ansible_user, ansible_ssh_pass ...) for your environment

3) run the play book

- Configure only the databases servers in HA 

```console
ansible-playbook -i inventory/environment.yml deploy_cluster.yml
```

- Configure only the app servers

```console
ansible-playbook -i inventory/environment.yml deploy_application.yml
```
<br >

---

Using de aplication:

 - Insert or update a registry
```bash
curl -X PUT -H 'Content-Type: application/json' -d '{"birthday":"1988-04-12"}' http://<host_ip>/hello/lola
```

- Get information about birthday
```bash
curl -X GET http://<host_ip>/hello/lola
```

or connect to database:

- connecting on pg master
```bash
psql -h <cluster_vip> -U dba postgres -p 5000
```
> password for dba user is `dba`

- connecting on pg replica
```bash
psql -h <cluster_vip> -U dba postgres -p 5001
```

- To check cluster health, we can enter HAProxy status page


```
https://<HAProxy_ip>:7000
```
**_NOTE: the user postgres is only acessible inside the host._**

- all ips and ports information to access the database or application are available in the playbook output executed by ansible.

