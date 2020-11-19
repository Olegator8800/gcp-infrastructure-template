sudo apt update
sudo apt -yq install apt-transport-https ca-certificates curl gnupg2 software-properties-common
curl -fsSL https://download.docker.com/linux/debian/gpg | sudo apt-key add -
sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/debian $(lsb_release -cs) stable"
sudo apt update
apt-cache policy docker-ce
sudo apt -yq install docker-ce

#docker daemon remote access
sudo mkdir -p /etc/systemd/system/docker.service.d
echo "[Service]" | sudo tee /etc/systemd/system/docker.service.d/options.conf
echo "ExecStart=" | sudo tee -a /etc/systemd/system/docker.service.d/options.conf
echo "ExecStart=/usr/bin/dockerd -H unix:// -H tcp://0.0.0.0:2375" | sudo tee -a /etc/systemd/system/docker.service.d/options.conf
sudo systemctl daemon-reload
sudo systemctl restart docker
