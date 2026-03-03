#!/bin/bash

set -e

echo "Updating system..."
sudo apt-get update -y

echo "Installing required packages..."
sudo apt-get install -y curl wget unzip software-properties-common ca-certificates gnupg

########################################
# Install Java (OpenJDK 17 recommended)
########################################
echo "Installing Java..."
sudo apt-get install -y openjdk-17-jdk

echo "Java version:"
java -version

########################################
# Install Maven
########################################
echo "Installing Maven..."
sudo apt-get install -y maven

echo "Maven version:"
mvn -version

########################################
# Install Node.js + npm (LTS)
########################################
echo "Installing Node.js LTS..."
curl -fsSL https://deb.nodesource.com/setup_lts.x | sudo -E bash -
sudo apt-get install -y nodejs

echo "Node + npm versions:"
node -v
npm -v

########################################
# Install Angular CLI
########################################
echo "Installing Angular CLI..."
sudo npm install -g @angular/cli

echo "Angular version:"
ng version

########################################
# .NET SDK (C#)
########################################
echo "Installing .NET SDK..."

# Add Microsoft package repo
wget https://packages.microsoft.com/config/ubuntu/$(lsb_release -rs)/packages-microsoft-prod.deb -O packages-microsoft-prod.deb
sudo dpkg -i packages-microsoft-prod.deb
rm packages-microsoft-prod.deb

# Install SDK
sudo apt-get update
sudo apt-get install -y dotnet-sdk-8.0

echo ".NET Version:"
dotnet --version


########################################
# Done
########################################
echo "All tools installed successfully!"