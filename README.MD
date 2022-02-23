to run plan, the -vra-file must be specified:
ex: terraform plan -var-file="environments/dev/main-vars.tfvars"

to run init, the backend config file must be specified
ex: terraform init -backend-config="environments/dev/backend-config.hcl"
