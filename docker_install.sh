# https://transfersh.pleasemarkdarkly.com/zKQz0/docker_install.sh

sudo apt-get remove -y docker docker-engine docker.io containerd runc
sudo apt-get install -y libffi-dev libssl-dev
sudo apt-get install -y python python-pip
sudo apt-get remove -y python-configparser

sudo apt-get update -y

sudo apt install -y \
     apt-transport-https \
     ca-certificates \
     curl \
     software-properties-common

curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
sudo apt-key fingerprint 0EBFCD88

sudo add-apt-repository \
   "deb [arch=arm64] https://download.docker.com/linux/debian \
   "disco" \
   stable"

sudo apt-get update -y

mkdir docker_installs
cd docker_installs

wget https://download.docker.com/linux/debian/dists/buster/pool/stable/arm64/containerd.io_1.2.10-3_arm64.deb
wget https://download.docker.com/linux/debian/dists/buster/pool/stable/arm64/docker-ce-cli_18.09.9~3-0~debian-buster_arm64.deb
wget https://download.docker.com/linux/debian/dists/buster/pool/stable/arm64/docker-ce_18.09.9~3-0~debian-buster_arm64.deb

# sudo apt-get install docker-ce docker-ce-cli containerd.io

sudo dpkg -i containerd.io_1.2.10-3_arm64.deb
sudo dpkg -i docker-ce-cli_18.09.9~3-0~debian-buster_arm64.deb
sudo dpkg -i docker-ce_18.09.9~3-0~debian-buster_arm64.deb

sudo systemctl start docker
sudo systemctl enable docker

sudo pip install docker-compose
usermod -aG sudo $(whoami)
usermod -aG docker $(whomami)

