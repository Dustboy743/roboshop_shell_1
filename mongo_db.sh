#!/bin/bash
source ./common_code.sh

install_app="mongodb-org"
service="mongod"

rm -rf /etc/yum.repos.d/mongo.repo
cp $current_directory/mongo.repo /etc/yum.repos.d/mongo.repo
VALIDATION $? "Copying MongoDB repo"

sed -i 's/127.0.0.1/0.0.0.0/g' /etc/mongod.conf
VALIDATION $? "Editing MongoDB conf file for remote connections"

systemctl restart mongod &>>$log_name
VALIDATION $? "Restarting MongoDB"



    

