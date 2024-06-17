#!/bin/bash

# Update instance and install ansible
apt-get update -y
apt-get instance software-properties-command -y
add-apt-repository --yes --update ppa:ansible/ansible
apt-get install ansible -y
hostnamectl set-hostname ansible