#!/bin/bash
source ./common_code.sh
install_app="rabbitmq-server"
service="rabbitmq-server"

ROOT_CHECK

echo "enter the root password"
read -s ROOT_PASSWORD   

cp $current_directory/rabbitmq.repo /etc/yum.repos.d/rabbitmq.repo &>> $log_name
VALIDATION $? "Copying of repo"

SYSTEMCTL

rabbitmqctl add_user roboshop $ROOT_PASSWORD &>> $log_name
rabbitmqctl set_permissions -p / roboshop ".*" ".*" ".*" &>> $log_name
VALIDATION $? "permission set"

