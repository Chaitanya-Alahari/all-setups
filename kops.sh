#vim .bashrc
#export PATH=$PATH:/usr/local/bin/
#source .bashrc


#! /bin/bash
aws configure
curl -Lo kops https://github.com/kubernetes/kops/releases/download/$(curl -s https://api.github.com/repos/kubernetes/kops/releases/latest | grep tag_name | cut -d '"' -f 4)/kops-linux-amd64
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
chmod +x kops-linux-amd64 kubectl
mv kubectl /usr/local/bin/kubectl
mv kops-linux-amd64 /usr/local/bin/kops

export KOPS_STATE_STORE=s3://krishna03.k8s.local
kops create cluster --name chaitu.k8s.local --zones us-east-1a,us-east-1b --master-count=1 --master-size t2.medium --master-volume-size 25 --node-count=2 --node-size t2.medium --node-volume-size 25
kops update cluster --name chaitu.k8s.local --yes --admin
