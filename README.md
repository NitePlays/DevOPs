# DevOPs

This script is used to install the basic necessary things for DevOPs - Jenkins, Docker, Docker-Compose, SonarQube, AWS, Terraform

NOTE: Script is for Ubuntu 22.04

# SonarQube
The username SonarQube is: **sonarqube** and password is: **sonarqube**
If you like to change it, you can do it in line **31** and **32**

The same is for Postgresql database, you can change it in line **44**

# Tutorial

To use this script you need Git to be installed on your Ubuntu 22.04:
```
sudo apt-get update
sudo apt-get install git
```

Confirm, that git is installed:
```
git --version
```

Then clone my repository:
```
git clone https://github.com/NitePlays/DevOPs.git
```
Then give permissions to install.sh and run it
```
chmod +x install.sh
./install.sh
```
