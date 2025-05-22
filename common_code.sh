#!/bin/bash
red="\e[31m"
green="\e[32m"
yellow="\e[33m"
normal="\e[0m"
current_directory=$PWD  #to get the current working directory
log_folder="/var/log/roboshop_logs"   #create a folder
file_name=$(echo $0 | cut -d "." -f1) #to extract the name
log_name="$log_folder/$file_name.log"
user=$(id -u) 

mkdir -p $log_folder #create a log folder

echo "Script executed at $(date)" &>> $log_name
#$(id -u)  #checking the user
ROOT_CHECK()
{
    if [ $user -ne 0 ]
then 
    echo -e "$red You're not the root user $normal" | tee -a $log_name
    exit 1
else
    echo -e "$green You're a root user $normal"| tee -a $log_name
fi
}

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

NODEJS_INSTALL
{
    dnf module disable nodejs -y &>> $log_name
    VALIDATION $? "Disabling nodejs"

    dnf module enable nodejs:20 -y &>> $log_name
    VALIDATION $? "enabling nodejs:20"

    dnf install nodejs -y &>> $log_name
    VALIDATION $? "Installing nodejs"

    npm install | tee -a $log_name
    VALIDATION $? "Installing package"
}

SYSTEMCTL()
{
    dnf install $install_app -y &>> $log_name
    VALIDATION $? "$install_app installation"

    systemctl enable $service &>> $log_name
    VALIDATION $? "Enabling $service"

    systemctl start $service &>> $log_name
    VALIDATION $? "Starting $service" 
}

ROBOSHOP_USER
{
    id roboshop
    if [ $? -ne 0 ]
    then
        useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop &>> $log_name
        VALIDATION $? "useradd"
    else
        echo -e "System user roboshop already created ... $yellow SKIPPING $normal"
    fi    

    mkdir -p /app &>> $log_name
    curl -o /tmp/$application.zip https://roboshop-artifacts.s3.amazonaws.com/$application-v3.zip &>> $log_name
    VALIDATION $? "\Downloading $application"

    rm -rf /app/*  #removing because if we run the script 2nd time we again paste it
    cd /app 
    unzip /tmp/$application.zip &>> $log_name
}

DAEMON_RELOAD
{
    cp $current_directory/$application.service /etc/systemd/system/$application.service &>> $log_name
    VALIDATION $? "copying $application service"
    
    systemctl daemon-reload &>> $log_name
    VALIDATION $? "systmctl daemon-reload"

    systemctl enable $application &>> $log_name
    VALIDATION $? "Enabling $application"

    systemctl start $application &>> $log_name
    VALIDATION $? "Starting $application"
}

UNZIPPING
{

}