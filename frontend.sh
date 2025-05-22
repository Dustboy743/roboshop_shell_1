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


dnf module disable nginx -y &>> $log_name
dnf module enable nginx:1.24 -y &>> $log_name
dnf install nginx -y | tee -a &>> $log_name
VALIDATION $? "nginx installation" 

systemctl enable nginx &>> $log_name
systemctl start nginx &>> $log_name
VALIDATION $? "starting of nginx is" 

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
