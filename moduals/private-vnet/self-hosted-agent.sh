#!/bin/bash
set -e

#terraform apply -var="azp_token=YOUR_PAT_TOKEN"
# ============================================
# VARIABLES — change these
# ============================================
AZP_URL="https://dev.azure.com/sreenivasad0208"
AZP_TOKEN="CMcH7HBDhlNrYnssnUOpNI7shKOtJXQrveq8i7UqHgy6Dvu8bJ2WJQQJ99CBACAAAAAAAAAAAAASAZDO4DYg"
AZP_POOL="self-hosted"
AZP_AGENT_NAME="self-hosted-aks"
AZP_WORK="_work"
AGENT_VERSION="4.269.0"
AGENT_DIR="$HOME/myagent"



echo "Updating system..."
sudo apt-get update -y
sudo apt-get upgrade -y

# ============================================
# STEP 1 — Install Dependencies
# ============================================
echo "📦 Installing dependencies..."

# Wait for apt lock to release (common on fresh VMs)
while sudo fuser /var/lib/dpkg/lock-frontend >/dev/null 2>&1; do
  echo "Waiting for apt lock..."
  sleep 5
done

sudo apt-get update -y
sudo apt-get install -y \
  curl \
  wget \
  git \
  jq \
  libicu-dev \
  dos2unix


# ============================================
# STEP 2 — Install Docker
# ============================================
echo "🐳 Installing Docker..."
sudo apt-get install -y \
  ca-certificates \
  gnupg \
  lsb-release

curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg

echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] \
  https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

sudo apt-get update -y
sudo apt-get install -y docker-ce docker-ce-cli containerd.io

sudo usermod -aG docker adminuser
sudo systemctl enable docker
sudo systemctl start docker

echo "✅ Docker installed: $(docker --version)"

# ============================================
# STEP 3 — Download Azure Pipelines Agent
# ============================================
echo "⬇️ Downloading Azure Pipelines Agent v${AGENT_VERSION}..."

mkdir -p "$AGENT_DIR"
cd "$AGENT_DIR"

AGENT_PACKAGE="vsts-agent-linux-x64-${AGENT_VERSION}.tar.gz"
DOWNLOAD_URL="https://vstsagentpackage.azureedge.net/agent/${AGENT_VERSION}/${AGENT_PACKAGE}"

wget -q "$DOWNLOAD_URL" -O "$AGENT_PACKAGE"
tar -xzf "$AGENT_PACKAGE"
rm -f "$AGENT_PACKAGE"

echo "✅ Agent downloaded and extracted to $AGENT_DIR"



# ============================================
# STEP 4 — Configure Agent (Unattended)
# ============================================
echo "⚙️ Configuring Azure Pipelines Agent..."

"$AGENT_DIR/config.sh" \
  --unattended \
  --url "$AZP_URL" \
  --auth pat \
  --token "$AZP_TOKEN" \
  --pool "$AZP_POOL" \
  --agent "$AZP_AGENT_NAME" \
  --work "$AZP_WORK" \
  --acceptTeeEula \        # ✅ auto-accepts the license agreement you saw manually
  --replace               # ✅ replaces agent if already registered with same name

echo "✅ Agent configured successfully"


# ============================================
# STEP 5 — Install as systemd Service (auto-start)
# ============================================
echo "🔧 Installing agent as systemd service..."

sudo "$AGENT_DIR/svc.sh" install adminuser
sudo "$AGENT_DIR/svc.sh" start

# Verify service is running
sudo "$AGENT_DIR/svc.sh" status

echo "✅ Agent service started and enabled on boot"


# ============================================
# STEP 6 — Verify
# ============================================
echo ""
echo "================================================"
echo "✅ Self-Hosted Agent Setup Complete!"
echo "   URL:    $AZP_URL"
echo "   Pool:   $AZP_POOL"
echo "   Agent:  $AZP_AGENT_NAME"
echo "   Work:   $AGENT_DIR/$AZP_WORK"
echo "================================================"

##TODO INSTALL DEVOPS AGENT
#curl -o vsts-agent-linux-x64-4.269.0.tar.gz https://download.agent.dev.azure.com/agent/4.269.0/vsts-agent-linux-x64-4.269.0.tar.gz
#mkdir myagent
#tar zxvf vsts-agent-linux-x64-4.269.0.tar.gz -C myagent
#chmod -R 777 myagent
## Configuration of the self-hosted agent
#cd myagent
#./config.sh --unattended --url https://dev.azure.com/sreenivasad0208 --auth pat --token CMcH7HBDhlNrYnssnUOpNI7shKOtJXQrveq8i7UqHgy6Dvu8bJ2WJQQJ99CBACAAAAAAAAAAAAASAZDO4DYg --pool self-hosted --agent aksagent --acceptTeeEula
#./run.sh

exit 0