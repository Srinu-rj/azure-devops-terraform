#!/bin/bash
set -euo pipefail
trap 'echo "❌ Error on line $LINENO — exit code $?" >&2' ERR

# ============================================================
# CONFIGURATION
# ============================================================
AZP_URL="${AZP_URL:-https://dev.azure.com/sreenivasad0208}"
AZP_TOKEN="${AZP_TOKEN:-}"                            # ✅ no hard fail here, we validate below
AZP_POOL="${AZP_POOL:-self-hosted}"
AZP_AGENT_NAME="${AZP_AGENT_NAME:-self-hosted-pipeline}"
AZP_WORK="${AZP_WORK:-_work}"
AGENT_VERSION="${AGENT_VERSION:-4.269.0}"
AGENT_DIR="${AGENT_DIR:-$HOME/myagent}"
ADMIN_USER="${ADMIN_USER:-adminuser}"

JAVA_VERSION="17"
MAVEN_VERSION="3.9.6"
DOTNET_VERSION="8.0"
NODE_VERSION="20"

DOCKER_INSTALL="${DOCKER_INSTALL:-true}"
MAVEN_INSTALL="${MAVEN_INSTALL:-true}"
JAVA_INSTALL="${JAVA_INSTALL:-true}"
DOTNET_INSTALL="${DOTNET_INSTALL:-true}"
ANGULAR_INSTALL="${ANGULAR_INSTALL:-true}"
NMAP_INSTALL="${NMAP_INSTALL:-true}"

# ============================================================
# HELPER FUNCTIONS
# ============================================================
log()     { echo ""; echo "🔹 [$(date '+%Y-%m-%d %H:%M:%S')] $*"; }
success() { echo "✅ $*"; }
warn()    { echo "⚠️  $*"; }
error()   { echo "❌ $*" >&2; exit 1; }

wait_for_apt() {
  log "Waiting for apt locks to release..."
  while sudo fuser /var/lib/dpkg/lock-frontend >/dev/null 2>&1 || \
        sudo fuser /var/lib/apt/lists/lock >/dev/null 2>&1; do
    echo "  apt is locked, retrying in 5s..."
    sleep 5
  done
  success "apt lock released"
}

check_root() {
  if [[ $EUID -eq 0 ]]; then
    error "Do not run as root. Use adminuser with sudo."
  fi
}

# ============================================================
# STEP 0 — Preflight Checks
# ============================================================
log "STEP 0 — Preflight checks"
check_root

# ✅ validate token with clear message
[[ -z "$AZP_TOKEN" ]] && error "AZP_TOKEN is empty! Pass it via: export AZP_TOKEN=yourtoken"
[[ -z "$AZP_URL" ]]   && error "AZP_URL is empty!"

success "Preflight checks passed"
echo "  URL:    $AZP_URL"
echo "  Pool:   $AZP_POOL"
echo "  Agent:  $AZP_AGENT_NAME"
echo "  Dir:    $AGENT_DIR"

# ============================================================
# STEP 1 — System Updates & Base Dependencies
# ============================================================
log "STEP 1 — Installing system dependencies"
wait_for_apt

sudo apt-get update -y
sudo apt-get install -y \
  curl wget git jq unzip tar dos2unix \
  apt-transport-https ca-certificates gnupg \
  lsb-release software-properties-common \
  libicu-dev libssl-dev libkrb5-3 zlib1g

success "Base dependencies installed"

# ============================================================
# STEP 2 — Install Java
# ============================================================
if [[ "$JAVA_INSTALL" == "true" ]]; then
  log "STEP 2 — Installing Java JDK ${JAVA_VERSION}"
  sudo apt-get install -y "openjdk-${JAVA_VERSION}-jdk"

  JAVA_HOME_PATH="/usr/lib/jvm/java-${JAVA_VERSION}-openjdk-amd64"
  sudo tee /etc/profile.d/java.sh > /dev/null <<EOF
export JAVA_HOME=${JAVA_HOME_PATH}
export PATH=\$PATH:\$JAVA_HOME/bin
EOF
  sudo chmod +x /etc/profile.d/java.sh
  source /etc/profile.d/java.sh

  sudo sed -i '/JAVA_HOME/d' /etc/environment
  echo "JAVA_HOME=${JAVA_HOME_PATH}" | sudo tee -a /etc/environment

  success "Java installed: $(java -version 2>&1 | head -1)"
else
  warn "Skipping Java (JAVA_INSTALL=false)"
fi

# ============================================================
# STEP 3 — Install Maven
# ============================================================
if [[ "$MAVEN_INSTALL" == "true" ]]; then
  log "STEP 3 — Installing Maven ${MAVEN_VERSION}"

  MAVEN_URL="https://downloads.apache.org/maven/maven-3/${MAVEN_VERSION}/binaries/apache-maven-${MAVEN_VERSION}-bin.tar.gz"
  MAVEN_DIR="/opt/maven"

  sudo mkdir -p "$MAVEN_DIR"
  wget -q "$MAVEN_URL" -O /tmp/maven.tar.gz
  sudo tar -xzf /tmp/maven.tar.gz -C "$MAVEN_DIR" --strip-components=1
  rm -f /tmp/maven.tar.gz

  sudo tee /etc/profile.d/maven.sh > /dev/null <<EOF
export MAVEN_HOME=${MAVEN_DIR}
export M2_HOME=${MAVEN_DIR}
export PATH=\$PATH:${MAVEN_DIR}/bin
EOF
  sudo chmod +x /etc/profile.d/maven.sh
  source /etc/profile.d/maven.sh

  success "Maven installed: $(mvn -version 2>&1 | head -1)"
else
  warn "Skipping Maven (MAVEN_INSTALL=false)"
fi

# ============================================================
# STEP 4 — Install Docker
# ============================================================
if [[ "$DOCKER_INSTALL" == "true" ]]; then
  log "STEP 4 — Installing Docker"

  sudo apt-get remove -y docker docker-engine docker.io containerd runc 2>/dev/null || true

  curl -fsSL https://download.docker.com/linux/ubuntu/gpg | \
    sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg

  echo "deb [arch=$(dpkg --print-architecture) \
    signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] \
    https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | \
    sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

  sudo apt-get update -y
  sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin

  sudo usermod -aG docker "$ADMIN_USER"
  sudo systemctl enable docker
  sudo systemctl start docker

  success "Docker installed: $(docker --version)"
else
  warn "Skipping Docker (DOCKER_INSTALL=false)"
fi

# ============================================================
# STEP 5 — Install Nmap
# ============================================================
if [[ "$NMAP_INSTALL" == "true" ]]; then
  log "STEP 5 — Installing Nmap"
  sudo apt-get install -y nmap
  success "Nmap installed: $(nmap --version | head -1)"
else
  warn "Skipping Nmap (NMAP_INSTALL=false)"
fi

# ============================================================
# STEP 6 — Install .NET SDK & ASP.NET Core
# ============================================================
if [[ "$DOTNET_INSTALL" == "true" ]]; then
  log "STEP 6 — Installing .NET SDK ${DOTNET_VERSION}"

  wget -q https://packages.microsoft.com/config/ubuntu/22.04/packages-microsoft-prod.deb \
    -O /tmp/packages-microsoft-prod.deb
  sudo dpkg -i /tmp/packages-microsoft-prod.deb
  rm -f /tmp/packages-microsoft-prod.deb

  wait_for_apt
  sudo apt-get update -y
  sudo apt-get install -y \
    dotnet-sdk-${DOTNET_VERSION} \
    aspnetcore-runtime-${DOTNET_VERSION}

  sudo tee /etc/profile.d/dotnet.sh > /dev/null <<EOF
export DOTNET_ROOT=/usr/share/dotnet
export DOTNET_CLI_TELEMETRY_OPTOUT=1
export PATH=\$PATH:\$DOTNET_ROOT:\$HOME/.dotnet/tools
EOF
  sudo chmod +x /etc/profile.d/dotnet.sh
  source /etc/profile.d/dotnet.sh

  success ".NET SDK installed: $(dotnet --version)"
else
  warn "Skipping .NET SDK (DOTNET_INSTALL=false)"
fi

# ============================================================
# STEP 7 — Install Node.js & Angular CLI
# ============================================================
if [[ "$ANGULAR_INSTALL" == "true" ]]; then
  log "STEP 7 — Installing Node.js ${NODE_VERSION} & Angular CLI"

  curl -fsSL https://deb.nodesource.com/setup_${NODE_VERSION}.x | sudo -E bash -
  sudo apt-get install -y nodejs

  sudo npm install -g @angular/cli
  ng analytics disable --global 2>/dev/null || true

  success "Node: $(node --version) | npm: $(npm --version) | Angular: $(ng version --skip-confirmation 2>/dev/null | grep 'Angular CLI' | head -1)"
else
  warn "Skipping Angular (ANGULAR_INSTALL=false)"
fi

# ============================================================
# STEP 8 — Download Azure Pipelines Agent
# ============================================================
log "STEP 8 — Downloading Azure Pipelines Agent v${AGENT_VERSION}"

AGENT_PACKAGE="vsts-agent-linux-x64-${AGENT_VERSION}.tar.gz"
DOWNLOAD_URL="https://vstsagentpackage.azureedge.net/agent/${AGENT_VERSION}/${AGENT_PACKAGE}"

# Clean up existing agent
if [[ -d "$AGENT_DIR" ]]; then
  warn "Existing agent found, removing..."
  if [[ -f "$AGENT_DIR/svc.sh" ]]; then
    cd "$AGENT_DIR"
    sudo ./svc.sh stop      2>/dev/null || true
    sudo ./svc.sh uninstall 2>/dev/null || true
  fi
  rm -rf "$AGENT_DIR"
fi

mkdir -p "$AGENT_DIR"
cd "$AGENT_DIR"

wget -q --show-progress "$DOWNLOAD_URL" -O "$AGENT_PACKAGE"
tar -xzf "$AGENT_PACKAGE"
rm -f "$AGENT_PACKAGE"

success "Agent downloaded to $AGENT_DIR"

# ============================================================
# STEP 9 — Configure Agent
# ============================================================
log "STEP 9 — Configuring agent (unattended)"

cd "$AGENT_DIR"

./config.sh \
  --unattended \
  --url "$AZP_URL" \
  --auth pat \
  --token "$AZP_TOKEN" \
  --pool "$AZP_POOL" \
  --agent "$AZP_AGENT_NAME" \
  --work "$AZP_WORK" \
  --acceptTeeEula \
  --replace

success "Agent configured — Pool: $AZP_POOL | Name: $AZP_AGENT_NAME"

# ============================================================
# STEP 10 — Write Agent .env
# ============================================================
log "STEP 10 — Writing .env for agent"

cat > "$AGENT_DIR/.env" <<EOF
JAVA_HOME=/usr/lib/jvm/java-${JAVA_VERSION}-openjdk-amd64
MAVEN_HOME=/opt/maven
M2_HOME=/opt/maven
DOTNET_ROOT=/usr/share/dotnet
DOTNET_CLI_TELEMETRY_OPTOUT=1
DOCKER_HOST=unix:///var/run/docker.sock
PATH=$PATH:/usr/lib/jvm/java-${JAVA_VERSION}-openjdk-amd64/bin:/opt/maven/bin:/usr/share/dotnet:/usr/local/bin
EOF

success ".env written"

# ============================================================
# STEP 11 — Install as systemd Service
# ============================================================
log "STEP 11 — Installing agent as systemd service"

cd "$AGENT_DIR"
sudo ./svc.sh install "$ADMIN_USER"
sudo ./svc.sh start

SERVICE_NAME=$(cat "$AGENT_DIR/.service" 2>/dev/null || echo "vsts.agent.*")
sudo systemctl status "$SERVICE_NAME" --no-pager || true

success "Agent service started"

# ============================================================
# STEP 12 — Final Verification
# ============================================================
log "STEP 12 — Final Verification"

echo ""
echo "================================================"
echo "  Java:    $(java -version 2>&1 | head -1)"
echo "  Maven:   $(mvn -version 2>&1 | head -1)"
echo "  Docker:  $(docker --version 2>/dev/null          || echo 'not installed')"
echo "  .NET:    $(dotnet --version 2>/dev/null           || echo 'not installed')"
echo "  Node:    $(node --version 2>/dev/null             || echo 'not installed')"
echo "  npm:     $(npm --version 2>/dev/null              || echo 'not installed')"
echo "  Angular: $(ng version --skip-confirmation 2>/dev/null | grep 'Angular CLI' | head -1 || echo 'not installed')"
echo "  Nmap:    $(nmap --version 2>/dev/null | head -1   || echo 'not installed')"
echo "  Pool:    $AZP_POOL"
echo "  Agent:   $AZP_AGENT_NAME"
echo "  Dir:     $AGENT_DIR"
echo "================================================"
echo "✅ Azure Self-Hosted Agent is LIVE!"
echo "   Status: sudo systemctl status $SERVICE_NAME"
echo "   Logs:   journalctl -u $SERVICE_NAME -f"
echo "================================================"