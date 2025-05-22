#!/bin/bash
source ./common_code.sh
appname="shipping"

ROOT_CHECK

echo "Please enter root password to setup"
read -s MYSQL_ROOT_PASSWORD

dnf install maven -y &>> $log_name
VALIDATION $? "installing maven"

ROBOSHOP_USER

mvn clean package  &>> $log_name
mv target/shipping-1.0.jar shipping.jar &>> $log_name
VALIDATION $? "renaming of file"

DAEMON_RELOAD

dnf install mysql -y  &>> $log_name
VALIDATION $? "installing of mysql"

#to check already data is copied
#mysql -h mysql.jiony.xyz -uroot -p$MYSQL_ROOT_PASSWORD -e 'use cities' &>>$log_name
#if [ &? -ne 0 ]
#then #loading data
mysql -h mysql.jiony.xyz -uroot -p$MYSQL_ROOT_PASSWORD < /app/db/schema.sql &>>$log_name
VALIDATION $? "loading data into mysql"
mysql -h mysql.jiony.xyz -uroot -p$MYSQL_ROOT_PASSWORD < /app/db/app-user.sql  &>>$log_name
VALIDATION $? "loading data into mysql"
mysql -h mysql.jiony.xyz -uroot -p$MYSQL_ROOT_PASSWORD < /app/db/master-data.sql &>>$log_name
VALIDATION $? "loading data into mysql"

systemctl restart shipping &>>$log_name
VALIDATION $? "restart shipping"
