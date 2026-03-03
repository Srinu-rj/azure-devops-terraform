# ✅ No need to specify — auto loaded
terraform init
terraform plan
terraform apply
terraform apply -auto-approve

# ── Plan ──────────────────────────────────────────────────
terraform plan -var-file="dev.tfvars"
terraform plan -var-file="prod.tfvars"
terraform plan -var-file="staging.tfvars"

# ── Apply ─────────────────────────────────────────────────
terraform apply -var-file="dev.tfvars"
terraform apply -var-file="prod.tfvars"
terraform apply -var-file="staging.tfvars"

# ── Apply without confirmation prompt ─────────────────────
terraform apply -var-file="dev.tfvars"     -auto-approve
terraform apply -var-file="prod.tfvars"    -auto-approve
terraform apply -var-file="staging.tfvars" -auto-approve