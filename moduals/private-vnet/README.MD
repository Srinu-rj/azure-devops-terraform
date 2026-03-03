export AZP_TOKEN="CMcH7HBDhlNrYnssnUOpNI7shKOtJXQrveq8i7UqHgy6Dvu8bJ2WJQQJ99CBACAAAAAAAAAAAAASAZDO4DYg"
export AZP_URL="https://dev.azure.com/sreenivasad0208"
export AZP_POOL="kubernetes"
export AZP_AGENT_NAME="self-hosted-pipeline"

set AZP_TOKEN=CMcH7HBDhlNrYnssnUOpNI7shKOtJXQrveq8i7UqHgy6Dvu8bJ2WJQQJ99CBACAAAAAAAAAAAAASAZDO4DYg
set AZP_URL=https://dev.azure.com/sreenivasad0208
set AZP_POOL=kubernetes
set AZP_AGENT_NAME=self-hosted-pipeline


chmod +x self-hosted-agent.sh
./self-hosted-agent.sh