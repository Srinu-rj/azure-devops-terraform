# TODO JUST LOGIN AZ VM AND VERIFY ALL PACKAGES
ssh -i D:/azure_keys/private_key.pem adminuser@20.41.251.143

# Check all tools at once
java -version && \
mvn -version && \
dotnet --version && \
node --version && \
ng version --skip-confirmation && \
nmap --version && \
docker --version

# Check agent is running
sudo systemctl status vsts.agent.*

# Watch agent logs live
journalctl -u vsts.agent.* -f