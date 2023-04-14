#!/bin/bash

export DEBIAN_FRONTEND=noninteractive

# Install Jenkins
sudo apt-get update
sudo apt-get install -y openjdk-11-jdk
curl -fsSL https://pkg.jenkins.io/debian-stable/jenkins.io.key | sudo apt-key add -
sudo sh -c 'echo deb http://pkg.jenkins.io/debian-stable binary/ > /etc/apt/sources.list.d/jenkins.list'
sudo apt-get update
sudo apt-get install -y jenkins
sudo systemctl start jenkins
sudo systemctl enable jenkins

# Install SonarQube
sudo apt-get install -y gnupg
sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 0x8FCCA13FEF1D0C2B
sudo add-apt-repository "deb https://dl.bintray.com/sonarsource/deb-cli stable main"
sudo apt-get update
sudo apt-get install sonar-scanner -y
sudo systemctl start sonarqube
sudo systemctl enable sonarqube

# Install Docker
sudo apt-get update
sudo apt-get install -y apt-transport-https ca-certificates curl gnupg lsb-release
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
echo \
  "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update
sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
sudo usermod -aG docker $USER

# Install AWS CLI
sudo apt-get update
sudo apt-get install -y awscli

# Install Terraform
sudo apt-get update
sudo apt-get install wget unzip -y
LATEST_TERRAFORM_VERSION=$(curl -s https://releases.hashicorp.com/index.json | jq -r '.terraform.versions[].version' | grep -v -- '-beta' | sort -V | tail -n1)
wget "https://releases.hashicorp.com/terraform/${LATEST_TERRAFORM_VERSION}/terraform_${LATEST_TERRAFORM_VERSION}_linux_amd64.zip"
unzip "terraform_${LATEST_TERRAFORM_VERSION}_linux_amd64.zip"
sudo mv terraform /usr/local/bin/
terraform --version
