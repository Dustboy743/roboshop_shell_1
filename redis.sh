#!/bin/bash
source ./common_code.sh

ROOT_CHECK

dnf module disable redis -y  &>> $log_name
dnf module enable redis:7 -y &>> $log_name
VALIDATION $? "Redis enable" 

dnf install redis -y | tee -a $log_name
VALIDATION $? "Redis install" 

sed -i 's/127.0.0.1/0.0.0.0/g' /etc/redis/redis.conf &>> $log_name
sed -i 's/protected-mode yes/protected-mode no/g' /etc/redis/redis.conf &>> $log_name
VALIDATION $? "edit the conf file"

systemctl enable redis  &>> $log_name
systemctl start redis  &>> $log_name
VALIDATION $? "STARTING OF REDIS"
