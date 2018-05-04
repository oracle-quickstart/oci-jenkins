## Create VCN and Deploy Jenkins Cluster
This example creates one VCN in Oracle Cloud Infrastructure including default route table, DHCP options and subnets from scratch, then use the terraform_oci_jenkins module to deploy a Jenkins cluster.

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
