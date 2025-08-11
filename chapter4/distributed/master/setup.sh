#!/bin/bash

set -euo pipefail

echo "Installing Jenkins stable release with Amazon Corretto Java 17..."

#–– Wait for yum lock to be free
while fuser /var/run/yum.pid &>/dev/null; do
  echo "Waiting for yum lock to be released..."
  sleep 5
done

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

#–– Add Jenkins repo & key
wget -O /etc/yum.repos.d/jenkins.repo https://pkg.jenkins.io/redhat-stable/jenkins.repo
rpm --import https://pkg.jenkins.io/redhat-stable/jenkins.io-2023.key

#–– Upgrade system & install Jenkins package
yum clean all
yum upgrade -y
yum install -y jenkins

#–– Enable Jenkins to start on boot
systemctl enable jenkins

#–– Install Git
echo "Installing Git..."
yum install -y git

#–– Setup SSH for Jenkins user
echo "Setting up SSH key for Jenkins..."
mkdir -p /var/lib/jenkins/.ssh
chmod 700 /var/lib/jenkins/.ssh
touch /var/lib/jenkins/.ssh/known_hosts
ssh-keyscan github.com >> /var/lib/jenkins/.ssh/known_hosts
chown -R jenkins:jenkins /var/lib/jenkins/.ssh

if [ -f /tmp/id_rsa ]; then
  mv /tmp/id_rsa /var/lib/jenkins/.ssh/id_rsa
  chmod 600 /var/lib/jenkins/.ssh/id_rsa
  chown jenkins:jenkins /var/lib/jenkins/.ssh/id_rsa
else
  echo "⚠️  /tmp/id_rsa not found; skipping private-key install."
fi

#–– Place init-groovy scripts
echo "Configuring Jenkins initialization scripts..."
mkdir -p /var/lib/jenkins/init.groovy.d
mv /tmp/scripts/*.groovy /var/lib/jenkins/init.groovy.d/ 2>/dev/null || true
chown -R jenkins:jenkins /var/lib/jenkins/init.groovy.d

#–– Drop in Jenkins config
if [ -f /tmp/config/jenkins ]; then
  mv /tmp/config/jenkins /etc/sysconfig/jenkins
fi

#–– Install Jenkins plugins
echo "Installing Jenkins plugins..."
chmod +x /tmp/config/install-plugins.sh
mkdir -p /var/lib/jenkins/plugins
chown -R jenkins:jenkins /var/lib/jenkins/plugins
bash /tmp/config/install-plugins.sh

#–– Start Jenkins
echo "Starting Jenkins..."
systemctl start jenkins

echo "✅ Jenkins installed, plugins deployed, and service started."