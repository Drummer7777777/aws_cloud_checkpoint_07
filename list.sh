#!/bin/bash

mapfile -t regions <<< $(cat ~/aws_cloud/checkpoint_07/regions_allowed.conf)

for reg in "${!regions[@]}"; do
	echo '__________________'${regions[$reg]}'________________________'
	aws ec2 describe-instances \
       		--filters "Name=tag-value,Values=cec" "Name=instance-state-name,Values=running" \
		--region ${regions[$reg]} \
       		--query "Reservations[*].Instances[*].[InstanceId, NetworkInterfaces[].[PrivateIpAddresses[].Association[].PublicIp], Tags[?Key=='OS_type'].Value]" \
		--output text
done
       		#--query "Resrvations[*].Instances[*].[InstanceId, NetworkInterfaces[].[PrivateIpAddresses[].Association[].PublicIp], Tags[?Key=='OS_type'].Value]" \
