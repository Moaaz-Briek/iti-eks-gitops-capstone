#!/bin/bash
/etc/eks/bootstrap.sh ${cluster_name}

# Install k8s
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"

install -o root -g root -m 0755 kubectl /usr/bin/kubectl

rm kubectl

aws eks --region ${region} update-kubeconfig --name ${cluster_name}

echo "${region}" > region
echo "${role_arn}" > role

# install ssm & git
yum install -y amazon-ssm-agent git

curl -o deploy.sh https://raw.githubusercontent.com/danielfarag/iti-eks-gitops-capstone/main/utils/sh/deploy.sh

chmod +x deploy.sh

systemctl enable amazon-ssm-agent
systemctl restart amazon-ssm-agent  
