### Prepare befor using this example
```
1. Set up related network
```
Virtual network should be set up in Oracle data centers including default route table, DHCP options, security list and subnets .Subdivisions you define in a VCN (for example, 10.0.0.0/24 and 10.0.1.0/24). Subnets contain virtual network interface cards (VNICs), which attach to instances. If using private net please follow:

        1.1. Nat gate is setted up.When deploy jenkins node , please use subnet using nat.

        1.2. Bastion machine is setted up and public ip is bation_host.

        1.3. Loadbanlance is setted up and the it's ip is lb_public_ip.

### Using this example
Update terraform.tfvars with the required information.

#### Deploy the cluster  
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
