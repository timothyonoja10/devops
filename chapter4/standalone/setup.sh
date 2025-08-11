#!/bin/bash

echo "Installing Jenkins stable release with Amazon Corretto Java 17..."

# Wait for yum lock to be free
while fuser /var/run/yum.pid >/dev/null 2>&1; do
  echo "Waiting for yum lock to be released..."
  sleep 5
done

# Remove older Java versions if present
yum remove -y java || true

# Install Amazon Corretto 17
rpm --import https://yum.corretto.aws/corretto.key
curl -Lo /etc/yum.repos.d/corretto.repo https://yum.corretto.aws/corretto.repo
yum install -y java-17-amazon-corretto-devel

# Verify Java version
java -version || { echo "Java installation failed"; exit 1; }

# Add the Jenkins repository
wget -O /etc/yum.repos.d/jenkins.repo https://pkg.jenkins.io/redhat-stable/jenkins.repo
rpm --import https://pkg.jenkins.io/redhat-stable/jenkins.io-2023.key

# Upgrade and install Jenkins
yum upgrade -y
yum install -y jenkins

# Enable and start Jenkins
systemctl enable jenkins
systemctl start jenkins || { echo "Jenkins failed to start"; journalctl -xe; exit 1; }

echo "✅ Jenkins installed and running with Amazon Corretto 17."