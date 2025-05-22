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

dnf module disable nodejs -y &>> $log_name
VALIDATION $? "Disabling nodejs"

dnf module enable nodejs:20 -y &>> $log_name
VALIDATION $? "enabling nodejs:20"

dnf install nodejs -y &>> $log_name
VALIDATION $? "Installing nodejs"

id roboshop
if [ $? -ne 0 ]
then
    useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop &>> $log_name
    VALIDATION $? "useradd"
else
    echo -e "System user roboshop already created ... $yellow SKIPPING $normal"
fi    
    
mkdir -p /app &>> $log_name

rm -rf /app/*
curl -L -o /tmp/user.zip https://roboshop-artifacts.s3.amazonaws.com/user-v3.zip &>> $log_name
cd /app 
unzip /tmp/user.zip &>> $log_name
VALIDATION $? "unzipping of file"

npm install &>> $log_name
VALIDATION $? "Installing Dependencies"

cp $current_directory/user.service /etc/systemd/system/user.service &>> $log_name
VALIDATION $? "Copying of file"

systemctl daemon-reload &>> $log_name
VALIDATION $? "systmctl daemon-reload"

systemctl enable user &>> $log_name
VALIDATION $? "Enabling user"

systemctl start user &>> $log_name
VALIDATION $? "Starting user"


