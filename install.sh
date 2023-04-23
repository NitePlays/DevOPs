#!/bin/bash

export DEBIAN_FRONTEND=noninteractive

# Install Jenkins
sudo apt-get update
sudo apt-get install wget unzip -y
sudo apt-get install -y openjdk-17-jdk
curl -fsSL https://pkg.jenkins.io/debian-stable/jenkins.io-2023.key | sudo tee /usr/share/keyrings/jenkins-keyring.asc > /dev/null
echo deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc] https://pkg.jenkins.io/debian-stable binary/ | sudo tee /etc/apt/sources.list.d/jenkins.list > /dev/null
sudo apt-get update
sudo apt-get install -y jenkins
sudo systemctl start jenkins
sudo systemctl enable jenkins

# Download and install SonarQube
LATEST_VERSION=$(curl -s "https://api.github.com/repos/SonarSource/sonarqube/releases/latest" | grep -oP '"tag_name": "\K(.*)(?=")')
wget "https://binaries.sonarsource.com/Distribution/sonarqube/sonarqube-${LATEST_VERSION}.zip"
sudo unzip "sonarqube-${LATEST_VERSION}.zip"
sudo mv "sonarqube-${LATEST_VERSION}" /opt/sonarqube
sudo adduser --system --no-create-home --group --disabled-login sonarqube
sudo chown -R sonarqube:sonarqube /opt/sonarqube
sudo rm "sonarqube-${LATEST_VERSION}.zip"

# Configure System
sudo useradd -b /opt/sonarqube -s /bin/bash sonarqube
sudo sh -c 'echo "vm.max_map_count=524288\nfs.file-max=131072" >> /etc/sysctl.conf'
sudo sh -c 'echo "sonarqube - nofile 131072\nsonarqube - nproc 8192" >> /etc/security/limits.d/99-sonarqube.conf'

# Configure SonarQube
sudo sed -i 's|#sonar.jdbc.username=|sonar.jdbc.username=sonarqube|g' /opt/sonarqube/conf/sonar.properties
sudo sed -i 's|#sonar.jdbc.password=|sonar.jdbc.password=sonarqube|g' /opt/sonarqube/conf/sonar.properties
sudo sed -i 's|#sonar.jdbc.url=jdbc:postgresql://localhost/sonarqube?currentSchema=my_schema|sonar.jdbc.url=jdbc:postgresql://localhost:5432/sonarqube|g' /opt/sonarqube/conf/sonar.properties
sudo sed -i 's|#sonar.search.javaOpts=-Xmx512m -Xms512m -XX:MaxDirectMemorySize=256m -XX:+HeapDumpOnOutOfMemoryError|sonar.search.javaOpts=-Xmx512m -Xms512m -XX:MaxDirectMemorySize=256m -XX:+HeapDumpOnOutOfMemoryError' /opt/sonarqube/conf/sonar.properties
sudo sed -i 's|#sonar.web.host=0.0.0.0|sonar.web.host=127.0.0.1|g' /opt/sonarqube/conf/sonar.properties
sudo sed -i 's|#sonar.web.port=9000|sonar.web.port=9000|g' /opt/sonarqube/conf/sonar.properties
sudo sed -i 's|#sonar.web.javaAdditionalOpts=|sonar.web.javaAdditionalOpts=-server|g' /opt/sonarqube/conf/sonar.properties
sudo sed -i 's|#sonar.log.level=INFO|sonar.log.level=INFO|g' /opt/sonarqube/conf/sonar.properties
sudo sed -i 's|#sonar.path.logs=logs|sonar.path.logs=logs|g' /opt/sonarqube/conf/sonar.properties
sudo sh -c 'echo "[Unit]\nDescription=SonarQube service\nAfter=syslog.target network.target\n\n[Service]\nType=forking\nExecStart=/opt/sonarqube/bin/linux-x86-64/sonar.sh start\nExecStop=/opt/sonarqube/bin/linux-x86-64/sonar.sh stop\nUser=sonarqube\nGroup=sonarqube\nRestart=always\nLimitNOFILE=65536\nLimitNPROC=a4096\n\n[Install]\nWantedBy=multi-user.target" > /etc/systemd/system/sonarqube.service'

# Install PostgreSQL
sudo apt-get install -y postgresql postgresql-contrib
sudo su postgres -c "psql -c \"CREATE USER sonarqube WITH ENCRYPTED PASSWORD 'sonarqube';\""
sudo su postgres -c "psql -c \"CREATE DATABASE sonarqube OWNER sonarqube ENCODING 'UTF8';\""
sudo su postgres -c "psql -c \"GRANT ALL PRIVILEGES ON DATABASE sonarqube TO sonarqube;\""

# Start SonarQube
sudo systemctl daemon-reload
sudo systemctl start sonarqube.service


# Install Docker
sudo apt-get update
sudo apt-get install -y apt-transport-https ca-certificates curl gnupg lsb-release
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
echo \  "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update
sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
sudo usermod -aG docker $USER

# Install AWS CLI
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install
export PATH="/usr/local/bin:$PATH"

# Install Terraform
sudo apt-get update
LATEST_TERRAFORM_VERSION=$(curl -s https://api.github.com/repos/hashicorp/terraform/releases/latest | grep tag_name | cut -d '"' -f 4 | cut -c 2-)
wget "https://releases.hashicorp.com/terraform/${LATEST_TERRAFORM_VERSION}/terraform_${LATEST_TERRAFORM_VERSION}_linux_amd64.zip"
unzip "terraform_${LATEST_TERRAFORM_VERSION}_linux_amd64.zip"
sudo mv terraform /usr/local/bin/
terraform --version
