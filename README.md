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

> **For testing proprose, you can use simples structure: pgnodes + etcd on the same server, using minimum 2 node. <br> :warning: Using this configuration remember to add the secerity groups rules for this 3 on the same security :warning:**

# Problem specification for the app

<details>
  <summary>Click for details</summary>

<br>

### 1. Design and code a simple "Hello World" application that exposes the following HTTP-based APIs:

<br>

#### Description: Saves/updates the given user’s name and date of birth in the database.

```console
Request: PUT /hello/<username> { “dateOfBirth”: “YYYY-MM-DD” }
Response: 204 No Content
```

> Note:<br>
> `<username>` must contain only letters.<br>
> `YYYY-MM-DD` must be a date before the today date.

<br>

#### Description:  Returns hello birthday message for the given user

```console
Request: Get /hello/<username>
Response: 200 OK
```

Response Examples:

A. If username’s birthday is in N days:
```console
{ “message”: “Hello, <username>! Your birthday is in N day(s)”}
```

B. If username’s birthday is today:
```console
{ “message”: “Hello, <username>! Happy birthday!” }
```

</details>

# How to use this repository

## Configuring on AWS arquiteture with terraform


<details>
  <summary>Click for details</summary>
  
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
</details>


---
## After launching the instances, you will need to configure and install the tools. For that you must run ansible.

---
### **Note: You can use ansible on your local machines if you want.**

## Configuring hosts with ansible

<details>
  <summary>details</summary>

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

- deploy everything

```console
ansible-playbook -i inventory/environment.yml deploy_all.yml
```

- Configure only the databases servers in HA 

```console
ansible-playbook -i inventory/environment.yml deploy_clusters.yml
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
curl -X PUT -H 'Content-Type: application/json' -d '{"dateOfBirth":"1988-04-12"}' http://<host_ip>/hello/lola
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

# Backup and Restore from s3

## pgBackRest 
:calendar: :watch: 

```bash
#change the variable:

pgbackrest_repo_type: "s3"

#add this lines on:

pgbackrest_conf:
  global:  
    - {option: "repo1-path", value: "{{ pgbackrest_repo_host }}"}
    - {option: "repo1-s3-endpoint", value: "s3endpoint"}
    - {option: "repo1-s3-bucket", value: "pgpgbackup-origin-"}
    - {option: "repo1-s3-verify-tls", value: "n"}
    - {option: "repo1-s3-key", value: "accessKey"}
    - {option: "repo1-s3-key-secret", value: "superSECRETkey"}
    - {option: "repo1-s3-region", value: "eu-east-1"}
    - {option: "delta", value: "y"}

pgbackrest_conf_host:
  global:
    - {option: "repo1-path", value: "{{ pgbackrest_bkp_dir }}"}
    - {option: "repo1-retention-full", value: "{{ pgbackrest_retention_full_bkp }}"}
    - {option: "repo1-retention-full-type", value: "{{ pgbackrest_retention_full_type }}"}
    - {option: "repo1-type", value: "{{ pgbackrest_repo_type |lower }}"}    
    - {option: "start-fast", value: "{{ pgbackrest_start_fast }}"}

```

- `vars/system.yml`

```bash
etc_hosts:
  - "192.168.122.157 pgbackrest.local s3endpoint"
```
## Backup command

-on postgres node:
```bash
sudo -u postgres pgbackrest --stanza=postgresql_cluster --log-level-console info backup
```

-on pgbackrest node:
```bash
sudo -u pgbackrest pgbackrest --stanza=postgresql_cluster --log-level-console info backup
```

## Restore command

-on postgres node:
```bash
#stop the cluster on this node
sudo systemctl stop patroni.service
```
> :bomb: if you run this command on master node, the failover will be execute 

retoring 1 database
```bash
postgres pgbackrest --stanza=postgresql_cluster --delta \
       --db-include=api --type=immediate --target-action=promote restore
```

retoring 1 database
```bash
postgres pgbackrest --stanza=postgresql_cluster --delta \
       --db-include=api --type=immediate --target-action=promote restore
```

for more information: https://pgbackrest.org/user-guide.html#quickstart/create-repository

</details>

---

# Administration tools

## patroniclt commands

<details>
  <summary>details</summary>

```bash
Usage: patronictl [OPTIONS] COMMAND [ARGS]...

Options:
  -c, --config-file TEXT  Configuration file
  -d, --dcs TEXT          Use this DCS
  -k, --insecure          Allow connections to SSL sites without certs
  --help                  Show this message and exit.

Commands:
  configure    Create configuration file
  dsn          Generate a dsn for the provided member, defaults to a dsn of...
  edit-config  Edit cluster configuration
  failover     Failover to a replica
  flush        Discard scheduled events
  history      Show the history of failovers/switchovers
  list         List the Patroni members for a given Patroni
  pause        Disable auto failover
  query        Query a Patroni PostgreSQL member
  reinit       Reinitialize cluster member
  reload       Reload cluster member configuration
  remove       Remove cluster from DCS
  restart      Restart cluster member
  resume       Resume auto failover
  scaffold     Create a structure for the cluster in DCS
  show-config  Show cluster configuration
  switchover   Switchover to a replica
  topology     Prints ASCII topology for given cluster
  version      Output version of patronictl command or a running Patroni...
```

</details>


## pgbackrest commands

<details>
  <summary>details</summary>

```bash
Usage:
    pgbackrest [options] [command]

Commands:
    archive-get     Get a WAL segment from the archive.
    archive-push    Push a WAL segment to the archive.
    backup          Backup a database cluster.
    check           Check the configuration.
    expire          Expire backups that exceed retention.
    help            Get help.
    info            Retrieve information about backups.
    repo-get        Get a file from a repository.
    repo-ls         List files in a repository.
    restore         Restore a database cluster.
    server          pgBackRest server.
    server-ping     Ping pgBackRest server.
    stanza-create   Create the required stanza data.
    stanza-delete   Delete a stanza.
    stanza-upgrade  Upgrade a stanza.
    start           Allow pgBackRest processes to run.
    stop            Stop pgBackRest processes from running.
    version         Get version.

Use 'pgbackrest help [command]' for more information.

```

</details>


