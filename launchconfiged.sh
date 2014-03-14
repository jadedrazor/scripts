#!/bin/bash
 set -xv
# TAGS =  Name, Project, Environment, Role, Project, CostCentre



LCNAME=$1
AMI=$2
INTTYPE=$3
USERDATA=$4
SG=$5
PROJECT=$6
ENV=$7
CC=$7

KEY=kaplan

BASE=`basename $0`


echo $BASE LaunchConfigName AMI-instance-id Instance-Type "UserData(take's URI's)" SecurityGroups Project CostCentre
aws autoscaling create-launch-configuration --launch-configuration-name "$LCNAME" --image-id="$AMI"  --instance-type "$INTTYPE" --user-data  "${USERDATA}" --security-groups $SG --key-name $KEY
