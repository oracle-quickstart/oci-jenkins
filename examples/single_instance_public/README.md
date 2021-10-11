## Create VCN and Deploy Jenkins Single Instance
This example creates a VCN in Oracle Cloud Infrastructure including default route table, DHCP options, security list and subnet from scratch, then use module to deploy a Jenkins Single Instance. 

### Using this example
Update terraform.tfvars with the required information.

### Deploy the cluster  
Initialize Terraform:
```
$ terraform init
```
View what Terraform plans do before actually doing it:
```
$ terraform plan
```
Use Terraform to Provision resources and Jenkins cluster on OCI:
```
$ terraform apply
```
