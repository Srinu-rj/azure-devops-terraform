#!/bin/bash

set -e

echo "Updating system..."
sudo apt-get update -y
sudo apt-get upgrade -y

echo "Installing basic tools..."
sudo apt-get install -y \
    curl \
    wget \
    git \
    unzip \
    zip \
    tar \
    htop \
    ufw \
    vim \
    nano \
    net-tools \
    dnsutils \
    software-properties-common \
    ca-certificates \
    gnupg \
    lsb-release \
    apt-transport-https

echo "Enabling firewall..."
sudo ufw allow OpenSSH
sudo ufw --force enable

echo "Cleaning up..."
sudo apt-get autoremove -y
sudo apt-get clean

echo "All tools installed successfully!"


# Create agent folder
mkdir -p ~/azagent && cd ~/azagent

# Download agent
curl -L -o agent.tar.gz https://download.agent.dev.azure.com/agent/4.269.0/vsts-agent-linux-x64-4.269.0.tar.gz

# Extract
tar zxvf agent.tar.gz

# Configure agent
./config.sh \
  --unattended \
  --url https://dev.azure.com/sreenivasad0208 \
  --auth pat \
  --token $AZP_TOKEN \
  --pool self-hosted \
  --agent aksagent \
  --acceptTeeEula

# Install as service
sudo ./svc.sh install
sudo ./svc.sh start
exit 0