#!/bin/bash -xe

##Install the needed packages and enable the services(MariaDb, Apache)
sudo yum update -y
sudo yum install git -y
sudo amazon-linux-extras install -y lamp-mariadb10.2-php7.2 php7.2
sudo yum install -y httpd mariadb-server
sudo systemctl start httpd
sudo systemctl enable httpd
sudo systemctl is-enabled httpd
sudo amazon-linux-extras install docker -y
sudo service docker start
sudo systemctl enable docker

##Add ec2-user to Apache group and grant permissions to /var/www
sudo usermod -a -G apache ec2-user
sudo chown -R ec2-user:apache /var/www
sudo chmod 2775 /var/www && find /var/www -type d -exec sudo chmod 2775 {} \;
find /var/www -type f -exec sudo chmod 0664 {} \;

sudo usermod -a -G docker ec2-user

cd /var/www/html

git clone https://github.com/stackitgit/CliXX_Retail_Repository.git
cp -r CliXX_Retail_Repository/* /var/www/html

## Allow wordpress to use Permalinks
sudo sed -i '151s/None/All/' /etc/httpd/conf/httpd.conf

##Grant file ownership of /var/www & its contents to apache user
sudo chown -R apache /var/www

##Grant group ownership of /var/www & contents to apache group
sudo chgrp -R apache /var/www

##Change directory permissions of /var/www & its subdir to add group write 
sudo chmod 2775 /var/www
find /var/www -type d -exec sudo chmod 2775 {} \;

##Recursively change file permission of /var/www & subdir to add group write perm
sudo find /var/www -type f -exec sudo chmod 0664 {} \;

##Restart Apache
sudo systemctl restart httpd
sudo service httpd restart

##Enable httpd 
sudo systemctl enable httpd

#Start SSM Agent
sudo systemctl start amazon-ssm-agent

sudo /sbin/sysctl -w net.ipv4.tcp_keepalive_time=200 net.ipv4.tcp_keepalive_intvl=200 net.ipv4.tcp_keepalive_probes=5

cd /var/www/html

sudo systemctl start httpd

sudo service docker start

sudo systemctl start mariadb

sudo sed -i 's/wordpress-db.cc5iigzknvxd.us-east-1.rds.amazonaws.com/${RDS_ENDPOINT}/' /var/www/html/wp-config.php

#---Updating the instance URL in the wordpress database
sudo mysql -u wordpressuser -h ${RDS_ENDPOINT} -pW3lcome123 wordpressdb <<EOF 
UPDATE wp_options SET option_value = "${lb_record}" WHERE option_value LIKE 'http%';
EOF

##Create Docker File
sudo touch Dockerfile

#Use an official Wordpress as a parent image
sudo bash -c 'echo -e "FROM wordpress:php7.1-apache\n" > Dockerfile'

#Set the working directory to /var/www/html
sudo bash -c 'echo -e "WORKDIR '/var/www/html'\n" >> Dockerfile'

#Copy the entire files in the working directory
sudo bash -c 'echo -e "COPY . /var/www/html\n" >> Dockerfile'

#Make port 80 available to the world outside this container
sudo bash -c 'echo -e "EXPOSE 80\n" >> Dockerfile'

##Build Docker Image
sudo docker build -t 'wp-image' .

sudo docker tag wp-image ${ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/${ECR_NAME}:${TAG}-1.0

sudo aws configure <<EOF
${DEV_ACCESS_KEY}
${DEV_SECRET_KEY}
${AWS_REGION}

EOF

sudo aws ecr get-login-password --region ${AWS_REGION} | sudo docker login --username AWS --password-stdin ${ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/${ECR_NAME}

sudo docker push ${ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/${ECR_NAME}:${TAG}-1.0

# sudo docker rm ${TAG}-1.0

# sudo rm -rf /var/www/html/*                  

#Start SSM Agent
sudo systemctl start amazon-ssm-agent