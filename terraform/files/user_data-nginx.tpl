#!/bin/bash
sudo yum update –y
sudo yum makecache -y
sudo yum install nginx -y
sudo /etc/init.d/nginx start