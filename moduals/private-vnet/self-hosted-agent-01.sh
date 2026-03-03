#!/bin/bash
set -e

#!/bin/bash

# Define variables
AGENT_DIR=~/azagent
AGENT_PACKAGE_URL="https://vstsagentpackage.azureedge.net/agent"
AGENT_PACKAGE="vsts-agent-linux-x64-3.232.1.tar.gz"
SERVER_URL="https://dev.azure.com/yourorganization"
PAT_TOKEN="CMcH7HBDhlNrYnssnUOpNI7shKOtJXQrveq8i7UqHgy6Dvu8bJ2WJQQJ99CBACAAAAAAAAAAAAASAZDO4DYg"
AUTH_TYPE="PAT"
AGENT_POOL="your_agent_pool"
AGENT_NAME="linux-agent-01"
WORK_FOLDER="_work"

# Create the directory for the agent
mkdir -p $AGENT_DIR && cd $AGENT_DIR

# Download the latest agent package
curl -O -L $AGENT_PACKAGE_URL/$AGENT_PACKAGE

# Extract the agent
tar zxvf $AGENT_PACKAGE

# Run the configuration script
./config.sh --unattended \
  --url $SERVER_URL \
  --auth $AUTH_TYPE \
  --token $PAT_TOKEN \
  --pool $AGENT_POOL \
  --agent $AGENT_NAME \
  --work $WORK_FOLDER

echo "Agent configuration completed!"

exit 0