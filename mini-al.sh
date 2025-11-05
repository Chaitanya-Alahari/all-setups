#vim .bashrc
#export PATH=$PATH:/usr/local/bin
#source .bashrc

yum update -y
yum install docker -y
systemctl start docker
systemctl enable docker
systemctl status docker

curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
mv kubectl /usr/local/bin/
chmod +x /usr/local/bin/kubectl

curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64
install minikube-linux-amd64 /usr/local/bin/minikube

yum install iptables -y
yum install conntrack -y
yum install socat ebtables -y

minikube start --driver=docker --force
minikube status
