#!/bin/bash
source ./common_code.sh
application=catalogue

ROOT_CHECK
ROBOSHOP_USER
NODEJS_INSTALL
DAEMON_RELOAD

cp $current_directory/mongo.repo /etc/yum.repos.d/mongo.repo
dnf install mongodb-mongosh -y &>> $log_name
VALIDATION $? "installing mongodb"

#will check whether mongodb data is already present or not to avoid copying multiple times
STATUS=$(mongosh --host mongodb.jiony.xyz --eval 'db.getMongo().getDBNames().indexOf("catalogue")')
if [ $STATUS -lt 0 ]
then
    mongosh --host mongodb.jiony.xyz </app/db/master-data.js &>>$log_name
    VALIDATION $? "Loading data into MongoDB"
else
    echo -e "Data is already loaded ... $yellow SKIPPING $normal"
fi