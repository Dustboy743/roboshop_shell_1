#!/bin/bash
source ./common_code.sh
install_app="mysql-server"
service="mysqld"

ROOT_CHECK

echo "Please enter root password to setup"
read -s MYSQL_ROOT_PASSWORD

SYSTEMCTL

mysql_secure_installation --set-root-pass $MYSQL_ROOT_PASSWORD &>> $log_name 
VALIDATION $? "Setting MySQL root password"