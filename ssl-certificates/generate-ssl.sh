sudo apt -yq install certbot
sudo certbot certonly -d ###PROJECT_NAME### -d *.###PROJECT_NAME### -m ###PROJECT_DNS_EMAIL### --manual --preferred-challenges dns
sudo cp /etc/letsencrypt/live/###PROJECT_DNS_NAME###/privkey.pem /etc/letsencrypt/live/###PROJECT_DNS_NAME###/domain.key
sudo bash -c 'cat /etc/letsencrypt/live/###PROJECT_DNS_NAME###/cert.pem /etc/letsencrypt/live/###PROJECT_DNS_NAME###/chain.pem > domain.crt'
sudo chmod 777 /etc/letsencrypt/live/###PROJECT_DNS_NAME###/domain.crt
sudo chmod 777 /etc/letsencrypt/live/###PROJECT_DNS_NAME###/domain.key
