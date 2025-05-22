#!/bin/bash
source ./common_code.sh
appname="frontend"
install_app="nginx"

ROOT_CHECK

dnf module disable nginx -y &>> $log_name
dnf module enable nginx:1.24 -y &>> $log_name

SYSTEMCTL

rm -rf /usr/share/nginx/html/* &>> $log_name
VALIDATION $? "removal of html files" 

curl -o /tmp/frontend.zip https://roboshop-artifacts.s3.amazonaws.com/frontend-v3.zip &>> $log_name

cd /usr/share/nginx/html &>> $log_name
unzip /tmp/frontend.zip  &>> $log_name
VALIDATION $? "extraction of html files"

cp $current_directory/nginx.conf /etc/nginx/nginx.conf &>> $log_name
VALIDATION $? "copying of nginx conf files"

systemctl restart nginx 
VALIDATION $? "sytemctl restart"
