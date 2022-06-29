# #!/bin/bash

# sudo yum update -y

# sudo amazon-linux-extras install -y lamp-mariadb10.2-php7.2 php7.2

# #---install the Apache web server and mariadb server
# sudo yum install -y httpd mariadb-server

# #---Start the Apache web server
# sudo systemctl start httpd

# #---Configure the Apache web server to start at each system boot
# sudo systemctl enable httpd

# sudo systemctl is-enabled httpd

# #---Install php----#
# sudo yum install php-mbstring -y

# #----Restart Apache and php----#
# sudo systemctl restart httpd
# sudo systemctl restart php-fpm

# cd /var/www/html

# sudo wget https://www.phpmyadmin.net/downloads/phpMyAdmin-latest-all-languages.tar.gz

# sudo mkdir phpMyAdmin && tar -xvzf phpMyAdmin-latest-all-languages.tar.gz -C phpMyAdmin --strip-components 1

# sudo rm phpMyAdmin-latest-all-languages.tar.gz

# cd /var/www/html/phpMyAdmin

# sudo mv config.sample.inc.php config.inc.php


# $i++;
# $cfg['Servers'][$i]['host'] = 'clixx-webdb-cluster.cwrtr9twvbxs.us-east-1.rds.amazonaws.com';
# $cfg['Servers'][$i]['port'] = '3306';
# $cfg['Servers'][$i]['verbose'] = 'Clixx-Wordpressdb';
# $cfg['Servers'][$i]['connect_type'] = 'tcp';
# $cfg['Servers'][$i]['extension'] = 'mysql';
# $cfg['Servers'][$i]['compress'] = TRUE;
# $cfg['Servers'][$i]['AllowNoPassword'] = false;

# sudo bash -c 'echo -e "\$cfg['Servers'][\$i]['port'] = '3306';\n" >> /var/www/html/phpMyAdmin/config.inc.php'
# sudo bash -c 'echo -e "\$cfg['Servers'][\$i]['verbose'] = 'Clixx-ECS-Wordpressdb';\n" >> /var/www/html/phpMyAdmin/config.inc.php'
# sudo bash -c 'echo -e "\$cfg['Servers'][\$i]['connect_type'] = 'tcp';\n" >> /var/www/html/phpMyAdmin/config.inc.php'
# sudo bash -c 'echo -e "\$cfg['Servers'][\$i]['extension'] = 'mysql';\n" >> /var/www/html/phpMyAdmin/config.inc.php'

#----Start Apache and php----#
sudo systemctl start httpd
sudo systemctl start php-fpm
sudo systemctl start mariadb

sudo sed -i "s/localhost/${RDS_ENDPOINT}/g" /var/www/html/phpMyAdmin/config.inc.php


#echo "Test page" >> /var/www/html/index.html

#Start SSM Agent
sudo systemctl start amazon-ssm-agent