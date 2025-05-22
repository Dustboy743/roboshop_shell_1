#!/bin/bash
source ./common_code.sh
appname="payment"

ROOT_CHECK

dnf install python3 gcc python3-devel -y &>> $log_name
VALIDATION $? "Installation of Python"

ROBOSHOP_USER

pip3 install -r requirements.txt &>> $log_name
VALIDATION $? "installation"

DAEMON_RELOAD