#!/bin/bash
  set -xv
# TAGS =  Name, Project, Environment, Role, Project, CostCentre



LCNAME=$1
AMI=$2
INTTYPE=$3
USERDATA=$4
SG=$5
MIN=$6
MAX=$7
DESIRED=$7
VPC=subnet-91dfdce5,subnet-c3fedd85
AVI="eu-west-1a eu-west-1b"
ELB=kp-10245-web-elb

KEY=kaplan

BASE=`basename $0`


echo $BASE LaunchConfigName AMI-instance-id Instance-Type "UserData(take's URI's)" SecurityGroups Project CostCentre


echo "Trying to create launch config $LCNAME"
aws autoscaling create-launch-configuration --launch-configuration-name "$LCNAME" --image-id="$AMI"  --instance-type "$INTTYPE" --user-data  "${USERDATA}" --security-groups $SG --key-name $KEY

echo "Trying to create auto-scale group $LCNAME-asg"
aws autoscaling   create-auto-scaling-group --launch-configuration-name "$LCNAME" --auto-scaling-group-name $LCNAME-asg --min-size $MIN --max-size $MAX --desired-capacity $DESIRED --availability-zones $AVI --vpc-zone-identifier $VPC --load-balancer-names $ELB
