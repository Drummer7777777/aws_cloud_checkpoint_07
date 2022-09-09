#!/bin/bash


while [ -n "$1" ]; do
	echo $1
	case "$1" in
		--region) region="$2";;
		--os) os="$2";;
	esac
	shift 2
done

os_array=(ubuntu al2)
mapfile -t regions <<< $(cat ~/aws_cloud/checkpoint_07/regions_allowed.conf)
for reg in "${!regions[@]}"; do
	if [[ "${regions[$reg]}" == "$region" ]]; then
		region_exist='True'
		break
	fi
done
for os_el in "${!os_array[@]}"; do
	if [[ "${os_array[$os_el]}" == "$os" ]]; then
		os_exist='True'
		break
	fi
done
echo $region_exist
echo $os_exist
#echo $region
#echo $os
if [[ "$region_exist" != "True" ]]; then
	echo 'Region '$region' invalid'
fi
if [[ "$os_exist" != "True" ]]; then
	echo 'OS '$os' invalid'
fi
if [[ "$region_exist" == "True" ]]; then
      if [[ "$os_exist" == "True" ]]; then
	
cat > ~/.aws/config << EOF
[default]
region = $region
output = json
EOF

amazon_linux_latest=$(aws ssm get-parameters --names /aws/service/ami-amazon-linux-latest/amzn2-ami-hvm-x86_64-gp2 --query 'Parameters[].Value' --output text)
ubuntu_linux_latest=$(aws ssm get-parameters --names /aws/service/canonical/ubuntu/server/20.04/stable/current/amd64/hvm/ebs-gp2/ami-id --query 'Parameters[].Value' --output text)

#tag_value_amazon="al2-ud7"
#tag_value_ubuntu="ubuntu-ud7"

declare amazon_linux
declare ubuntu_linux

amazon_linux=($amazon_linux_latest $tag_value_amazon)
ubuntu_linux=($ubuntu_linux_latest $tag_value_ubuntu)

declare distr_linux
distr_linux=($amazon_linux $ubuntu_linux)

#amazon_linux_latest=$(aws ssm get-parameters --names /aws/service/ami-amazon-linux-latest/amxn2-ami-hvm-x86_64-gp2 --query 'Parameters[].Value' --output text)
#ubuntu_linux_latest=$(aws ssm get-parameters --names /aws/service/canonical/ubuntu/server/20.04/stable/current/amd64/hvm/ebs-gp2/ami-id --query 'Parameters[].Value' --output text)


security_group_ids=$(aws ec2 describe-security-groups --group-names public-ssh-http-81 --query 'SecurityGroups[*].GroupId' --output text)
default_vpc_id=$(aws ec2 describe-vpcs --filters "Name=isDefault, Values=true" --query "Vpcs[*].VpcId" --output text)
subnet_id=$(aws ec2 describe-subnets --filters "Name=vpc-id, Values=$default_vpc_id" --query "Subnets[0].SubnetId" --output text)


#for instance in "${!distr_linux[@]}"; do
if [[ "$os" == "al2" ]]; then
	aws ec2 run-instances \
		--image-id $amazon_linux_latest \
		--count 1 \
		--instance-type t2.micro \
		--key-name student-ed25519 \
		--security-group-ids $security_group_ids \
		--subnet-id $subnet_id \
		--tag-specifications 'ResourceType=instance,Tags=[{Key=Name,Value='$os'-ud7},{Key=Type,Value=cec},{Key=OS_type,Value=Amazon linux}]' \
		--iam-instance-profile Name="CloudEngJ2Ch06Profile" \
		--debug \
		--user-data file://~/aws_cloud/checkpoint_07/user_data_for_install_cli_and_launch_script
#done
else
	aws ec2 run-instances \
		--image-id $ubuntu_linux_latest \
		--count 1 \
		--instance-type t2.micro \
		--key-name student-ed25519 \
		--security-group-ids $security_group_ids \
		--subnet-id $subnet_id \
		--tag-specifications 'ResourceType=instance,Tags=[{Key=Name,Value='$os'-ud7},{Key=Type,Value=cec},{Key=OS_type,Value=Ubuntu linux}]' \
		--iam-instance-profile Name="CloudEngJ2Ch06Profile" \
		--debug \
		--user-data file://~/aws_cloud/checkpoint_07/user_data_for_install_cli_and_launch_script
fi	
fi
fi
