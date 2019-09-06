#!/bin/bash


region_list=( us-east-1  eu-central-1  ap-southeast-1  ap-southeast-2)


for region in `echo ${region_list[*]}`
do
    instance_list=`aws ec2 describe-instances --filters  "Name=instance-state-name,Values=stopped" --query 'Reservations[].Instances[].InstanceId' --region $region | cut -d'"' -f2 | tr -d "]["`


    for instance in `echo ${instance_list[*]}`
        do 
            stack_name=`aws ec2 describe-instances --instance-id $instance --query "Reservations[*].Instances[*].[Tags[*]]" --output text --region $region  | grep opsworks:stack | awk '{print $2} ' `


            layer_name=`aws ec2 describe-instances --instance-id $instance --query "Reservations[*].Instances[*].[Tags[*]]" --output text --region $region | grep opsworks:layer | awk '{print $2} ' `


            instance_name=`aws ec2 describe-instances --instance-id $instance --query "Reservations[*].Instances[*].[Tags[*]]" --output text --region $region   |  grep opsworks:instance | awk '{print $2} ' `
            
            echo "$stack_name.$layer_name.instance_name">> stopped_instance_list
            #echo -e "==========\n"
        done
done
for x in `cat stopped_instance_list`
do
    find ./test -type f -name $x.cfg -exec  rm {} \;  #instead of ./test use your nagios config location
done


>stopped_instance_list        #removing the created file
