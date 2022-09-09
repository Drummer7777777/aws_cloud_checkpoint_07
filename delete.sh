#!/bin/bash

mapfile -t regions <<< $(cat ~/aws_cloud/checkpoint_07/regions_allowed.conf)

for reg in "${!regions[@]}"; do
        echo '__________________'${regions[$reg]}'________________________'

	id_arr=$(aws ec2 describe-instances \
	       	--filters "Name=tag-value,Values=cec" "Name=instance-state-name,Values=running" \
	       	--query "Reservations[*].Instances[*].InstanceId" \
		--region ${regions[$reg]} \
	       	--output text)
	echo ${id_arr[@]}

	if [[ -n $id_arr ]]; then
		aws ec2 terminate-instances --instance-ids ${id_arr[@]}
	fi
done
