#!/bin/bash

red="\e[31m"
green="\e[32m"
yellow="\e[33m"
normal="\e[0m"
current_directory=$PWD  #to get the current working directory
log_folder="/var/log/roboshop_logs"   #create a folder
file_name=$(echo $0 | cut -d "." -f1) #to extract the name
log_name="$log_folder/$file_name.log"
user=$(id -u)  #to get user ID

mkdir -p $log_folder #create a log folder
echo "Script executed at $(date)" &>> $log_name

#$(id -u)  #checking the user
if [ $user -ne 0 ]
then 
    echo -e "$red You're not the root user $normal" | tee -a $log_name
    exit 1
else
    echo -e "$green You're a root user $normal"| tee -a $log_name
fi

# validate functions takes input as exit status, what command they tried to install
VALIDATION()
{
    if [ $1 -eq 0 ]
    then   
        echo -e "$2 is $green SUCCESS $normal" | tee -a $log_name
    else   
        echo -e "$2 is $red FAILURE $normal" | tee -a $log_name
        exit 1
    fi    
}

dnf install maven -y &>> $log_name
VALIDATION $? "installing maven"

id roboshop
if [ $? -ne 0 ]
then
    useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop &>> $log_name
else
    echo -e "System user roboshop already created ... $yellow SKIPPING $normal"
fi

echo "Please enter root password to setup"
read -s MYSQL_ROOT_PASSWORD

mkdir -p /app
rm -rf /app/*    
curl -L -o /tmp/shipping.zip https://roboshop-artifacts.s3.amazonaws.com/shipping-v3.zip &>>$log_name
cd /app 
unzip /tmp/shipping.zip 
VALIDATION $? "unzipping of shipping"

mvn clean package  &>> $log_name
mv target/shipping-1.0.jar shipping.jar &>> $log_name
VALIDATION $? "renaming of file"

cp $current_directory/shipping.service /etc/systemd/system/shipping.service &>>$log_name
VALIDATION $? "copying of shipping file"

systemctl daemon-reload &>> $log_name
VALIDATION $? "systmctl daemon-reload"

systemctl enable shipping &>> $log_name
VALIDATION $? "Enabling shipping"

systemctl start shipping &>> $log_name
VALIDATION $? "Starting shipping"

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
