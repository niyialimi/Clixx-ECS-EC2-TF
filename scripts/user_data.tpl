#!/bin/bash

# Update all packages
sudo yum update -y
sudo yum install -y ecs-init
sudo service docker start
sudo start ecs

cluster_name="Clixx-Cluster-Tf"

#Adding cluster name in ecs config
sudo bash -c 'echo ECS_CLUSTER=${cluster_name} >> /etc/ecs/ecs.config'