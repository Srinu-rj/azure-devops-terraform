#!/bin/bash
set -e

echo "🔍 Checking Velero installation..."

# ── Check pods ───────────────────────────────────────────
echo ""
echo "📦 Velero Pods:"
kubectl get pods -n velero

# ── Check backup locations ────────────────────────────────
echo ""
echo "📍 Backup Storage Locations:"
velero backup-location get

# ── Check volume snapshot locations ──────────────────────
echo ""
echo "📸 Volume Snapshot Locations:"
velero snapshot-location get

# ── Check schedules ───────────────────────────────────────
echo ""
echo "🕐 Backup Schedules:"
velero schedule get

# ── Check existing backups ────────────────────────────────
echo ""
echo "💾 Existing Backups:"
velero backup get

# ── Check node agent ─────────────────────────────────────
echo ""
echo "🖥️ Node Agent:"
kubectl get daemonset -n velero

# ── Run test backup ───────────────────────────────────────
echo ""
echo "🚀 Running test backup..."
velero backup create test-backup-$(date +%Y%m%d) \
  --include-namespaces default \
  --wait

echo ""
echo "✅ Velero is working correctly!"