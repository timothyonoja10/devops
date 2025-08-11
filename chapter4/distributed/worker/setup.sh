#!/bin/bash

echo "Install Java"
#–– Remove any older Java versions if present
if rpm -q java >/dev/null 2>&1; then
  yum remove -y java
fi

#–– Install Amazon Corretto 17
rpm --import https://yum.corretto.aws/corretto.key
curl -Lo /etc/yum.repos.d/corretto.repo https://yum.corretto.aws/corretto.repo
yum install -y java-17-amazon-corretto-devel

#–– Verify Java
java -version

echo "Install Docker engine"
yum update -y
yum install docker -y
usermod -aG docker ec2-user
systemctl enable docker

echo "Install git"
yum install -y git