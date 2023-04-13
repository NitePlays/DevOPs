#!/bin/bash

# Install Jenkins
sudo apt-get update
sudo apt-get install openjdk-8-jdk -y
curl -fsSL https://pkg.jenkins.io/debian-stable/jenkins.io-2023.key | sudo tee /usr/share/keyrings/jenkins-keyring.asc > /dev/null
echo deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc] https://pkg.jenkins.io/debian-stable binary/ | sudo tee /etc/apt/sources.list.d/jenkins.list > /dev/null
sudo apt-get update
sudo apt-get install jenkins -y
sudo systemctl start jenkins
sudo systemctl enable jenkins

# Install SonarQube
sudo apt-get install -y gnupg
sudo wget -O /etc/apt/trusted.gpg.d/sonar.gpg https://binaries.sonarsource.com/Distribution/sonarqube/sonarqube-9.1.0.47736.zip.asc
sudo echo "deb https://binaries.sonarsource.com/Distribution/sonarqube/sonarqube-9.1.0.47736.zip /" | sudo tee -a /etc/apt/sources.list.d/sonarqube.list
sudo apt-get update
sudo apt-get install sonarqube -y
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
sudo apt-get install docker-ce docker-ce-cli containerd.io -y
sudo usermod -aG docker $USER

# Install AWS CLI
sudo apt-get update
sudo apt-get install awscli -y

# Install Terraform
sudo apt-get update
sudo apt-get install wget unzip -y
wget https://releases.hashicorp.com/terraform/1.0.10/terraform_1.0.10_linux_amd64.zip
unzip terraform_1.0.10_linux_amd64.zip
sudo mv terraform /usr/local/bin/
terraform --version
