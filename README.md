How to use this repository

### Configuring on AWS arquiteture
- Create the infaestructure on AWS cloud with terraform
```console
export AWS_ACCESS_KEY_ID="{YOU-KEY}"
export AWS_SECRET_ACCESS_KEY="{YOUR-SECRET-KEY}"
export AWS_SESSION_TOKEN="{WITH-USE-MFA}" # if necessary

terraform init
terraform plan -var-file=enviroments/hometask.tfvars
terraform apply -var-file=enviroments/hometask.tfvars
```

- Configure all servers that were launched by terraform

```console
ansible-playbook -i inventory/environment.yml deploy_enviroment.yml
```


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

After deploy the enviroment you can, use de aplication:

 - Insert or update a registry
```console
curl -X PUT -H 'Content-Type: application/json' -d '{"birthday":"1988-04-12"}' http://<host_ip>/hello/lola
```

- Get information about birthday
```console
curl -X GET http://<host_ip>/hello/lola
```

- all ips and ports information to directly access the database are available in the playbook output executed by ansible.


---
# Configuring on local arquiteture

- launch docker images
```console
docker-compose up -d
```

- Configure the app servers was launching by terraform
```console
foo@bar:~/Revolut/config_servers$ ansible-playbook -i hosts/database.yml application_setup.yml
```


---
### The automation deploy has been used on github-action
---