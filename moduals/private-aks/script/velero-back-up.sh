# ── Connect to AKS ───────────────────────────────────────
az aks get-credentials --resource-group aks-rg-prod --name my-aks-cluster

# ── Install Velero CLI ────────────────────────────────────
# Windows
choco install velero

# Linux / WSL
wget https://github.com/vmware-tanzu/velero/releases/download/v1.12.2/velero-v1.12.2-linux-amd64.tar.gz
tar -xzf velero-v1.12.2-linux-amd64.tar.gz
sudo mv velero-v1.12.2-linux-amd64/velero /usr/local/bin/

# ── Check status ──────────────────────────────────────────
velero backup-location get
velero schedule get
velero backup get

# ── Create manual backup ──────────────────────────────────
velero backup create manual-backup-prod \
  --include-namespaces production,staging \
  --storage-location default \
  --wait

# ── Create full cluster backup ────────────────────────────
velero backup create full-cluster-backup \
  --include-cluster-resources=true \
  --wait

# ── Describe backup ───────────────────────────────────────
velero backup describe manual-backup-prod
velero backup logs manual-backup-prod

# ── Restore full backup ───────────────────────────────────
velero restore create \
  --from-backup manual-backup-prod \
  --wait

# ── Restore specific namespace ────────────────────────────
velero restore create \
  --from-backup manual-backup-prod \
  --include-namespaces production \
  --wait

# ── Restore to different namespace ───────────────────────
velero restore create \
  --from-backup manual-backup-prod \
  --namespace-mappings production:production-restored \
  --wait

# ── Delete old backup ─────────────────────────────────────
velero backup delete manual-backup-prod

# ── Check restore status ──────────────────────────────────
velero restore get
velero restore describe <restore-name>