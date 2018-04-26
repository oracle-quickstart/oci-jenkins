# OCI authentication
tenancy_ocid = "ocid1.tenancy.oc1..aaaaaaaayfzsknabeptheebqsaicjddtlubq7dnwz5izbvs3vfs4xmkargta"
user_ocid = "ocid1.user.oc1..aaaaaaaazmwxesrcqs6gm6weo2htw2tirlws7bnu63k5hazbjgvhypta7kzq"
compartment_ocid = "ocid1.compartment.oc1..aaaaaaaahafkfbw4fafebajwyqwsgnbjkjy7ake3rgmpruouyaysg63lrh4q"
fingerprint= "c5:43:ce:89:af:40:6c:80:02:55:10:d3:1e:f2:10:1b"
private_key_path = "~/.oci/oci_api_key.pem"
region = "us-phoenix-1"

#Network Configration
master_ad = "uGEq:PHX-AD-1"
slave_ads = ["uGEq:PHX-AD-1", "uGEq:PHX-AD-2"]

#Instance Configration
ssh_authorized_keys = "~/.ssh/id_rsa.pub"
ssh_private_key = "~/.ssh/id_rsa"
slave_count = 2
