#!/bin/bash
# set -xv
#
# This script will create a launch configuration and attach that to a Auto Scale Group
# requires a file (which can be empty) that adds user data that will be applied to all instances
# Example file for user data
#
## #!/bin/bash
## # TAGS =  Name, Project, Environment, Role, CostCentre
## PROJECT=kplus
## ENV=p
## ROLE=web
## CC=Nathan
## INSTANCEID=$(curl -s 169.254.169.254/latest/meta-data/instance-id)
## MY_IP=$(curl -s 169.254.169.254/latest/meta-data/local-ipv4)
## DOMAINNAME=aws.kapintdc.com
## 	HOSTNAME=$PROJECT-10245-$ENV-$ROLE-$INSTANCEID
## 	hostname $HOSTNAME
## 	sed -i "s/HOSTNAME=.*/HOSTNAME=$HOSTNAME/" /etc/sysconfig/network
## echo "$MY_IP $HOSTNAME.$DOMAINNAME $HOSTNAME" >> /etc/hosts
## sed -i "s/search .*/search $DOMAINNAME/" /etc/resolv.conf

# This script parses the included user data script to pull out information which is used for tagging the instances, the tags are the constants from the script ( PROJECT ENV ROLE CC )
# hacked togethor by: Byron Jones
# Orginally written: 17/03/2014
# version 0.04

#
# When run you must supply 7 parameters
# 1 LCNAME which is the name of the launch config, -asg is appended to this for the auto scale group
# 2 AMI base AMI used for the instances
# 3 Instance type
# 4 User data file to include
# 5 security groups to attach to the instance
# 6 Minimum instances
# 7 Maximum instances
#
# This script also requires 4 constants to be set
# VPC contains a comma seperated list with the subnets the instances can be places in
# ELB the elastic load balancer to attach the instances to
# KEY the ssh key to attach to the instances

BASE=`basename $0`

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

PROJECT=`grep ^PROJECT= $USERDATA | awk -F\= '{ print $2 }'`
ENV=`grep ^ENV= $USERDATA | awk -F\= '{ print $2 }'`
ROLE=`grep ^ROLE= $USERDATA | awk -F\= '{ print $2 }'`
CC=`grep ^CC= $USERDATA | awk -F\= '{ print $2 }'`



echo $BASE LaunchConfigName AMI-instance-id Instance-Type "UserData(take's URI's)" SecurityGroups Project CostCentre


echo "Trying to create launch config $LCNAME"
aws autoscaling create-launch-configuration --launch-configuration-name "$LCNAME" --image-id="$AMI"  --instance-type "$INTTYPE" --user-data  file://"${USERDATA}" --security-groups $SG --key-name $KEY

echo "Trying to create auto-scale group $LCNAME-asg"
aws autoscaling   create-auto-scaling-group --launch-configuration-name "$LCNAME" --auto-scaling-group-name $LCNAME-asg --min-size $MIN --max-size $MAX --desired-capacity $DESIRED --availability-zones $AVI --vpc-zone-identifier $VPC --load-balancer-names $ELB --tags Key=Project,Value=$PROJECT,PropagateAtLaunch=true Key=Environment,Value=$ENV,PropagateAtLaunch=true Key=CostCentre,Value=$CC,PropagateAtLaunch=true Key=Role,Value=$ROLE,PropagateAtLaunch=true Key=Name,Value=$PROJECT-10245-$ENV-$ROLE,PropagateAtLaunch=true


