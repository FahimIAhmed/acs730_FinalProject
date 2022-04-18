#!/bin/bash

# Create mount volume for logs
  sudo su - root
  mkfs.ext4 /dev/sdf
  mount -t ext4 /dev/sdf /var/log

# Install & Start web server
  yum -y update
  yum -y install httpd
  sudo systemctl start httpd
  sudo systemctl enable httpd
  
  sudo aws s3 cp "s3://image-source-group8/image.jpg" /var/www/html/

# Print the hostname which includes instance details on homepage  
  myip=`curl http://169.254.169.254/latest/meta-data/local-ipv4`
  echo "<h1>Welcome to final project website ${prefix}! My private IP is <font color="Red"> $myip </font></h1><br>Presented by Group 8.</br><img src=""image.jpg"">"  >  /var/www/html/index.html
  
