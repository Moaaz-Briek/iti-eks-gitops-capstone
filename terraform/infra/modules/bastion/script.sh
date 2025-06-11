#!/bin/bash

apt update
apt install -y git  software-properties-common gnupg curl unzip

## INSTAL AWS CLI ##
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
./aws/install --install-dir /opt/aws-cli --bin-dir /usr/local/bin
rm awscliv2.zip


## Install terraform ##
wget https://releases.hashicorp.com/terraform/1.12.1/terraform_1.12.1_linux_amd64.zip
unzip terraform_1.12.1_linux_amd64.zip
mv terraform /usr/local/bin/



## Install kubectl ##
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
install -o root -g root -m 0755 kubectl /usr/bin/kubectl
rm kubectl



snap install amazon-ssm-agent --classic
systemctl enable amazon-ssm-agent
systemctl restart amazon-ssm-agent  

echo "sudo rm -r /root/iti-eks; git clone https://github.com/danielfarag/iti-eks-gitops-capstone /root/iti-eks" > /root/pull.sh 

chmod +x /root/pull.sh