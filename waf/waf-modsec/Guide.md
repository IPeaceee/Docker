docker compose build
docker compose up -d

#Install wazuh
curl -sO https://packages.wazuh.com/4.14/wazuh-install.sh && sudo bash ./wazuh-install.sh -a


#