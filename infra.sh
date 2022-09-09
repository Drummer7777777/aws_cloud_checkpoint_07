#!/bin/bash

security_groups=(public-ssh-and-http public-ssh-http-81)
#regions=$(aws ec2 describe-regions --all-regions --query "Regions[?OptInStatus  == 'opt-in-not-required'].RegionName" --output text)
#read -a regions <<< "$regions"
#read -a regions <<< $(cat ~/aws_cloud/checkpoint_07/regions_allowed.conf)
mapfile -t regions <<< $(cat ~/aws_cloud/checkpoint_07/regions_allowed.conf)
echo ${regions[@]}
echo ${regions[0]}
echo ${regions[-1]}
for region in "${regions[@]}"; do
	keys=(student-ed25519 student-rsa)
	echo "----------------Check $region-----------------------"
cat > ~/.aws/config << EOF
[default]
region = $region
output = json
EOF
	vpc_id=$(aws ec2 describe-vpcs --filters "Name=isDefault, Values=true" --query "Vpcs[].VpcId" --output text)
	#if [[ -z "$(aws ec2 describe-vpcs --filters "Name=isDefault, Values=true" --query "Vpcs[].VpcId" --output text)" ]]; then
	if [[ -z "$vpc_id" ]]; then
		echo "Create Default VPC"
		aws ec2 create-default-vpc
		vpc_id=$(aws ec2 describe-vpcs --filters "Name=isDefault, Values=true" --query "Vpcs[].VpcId" --output text)
	else
		echo "Default VPC exist"
	fi
	availability_zones=$(aws ec2 describe-availability-zones --filters "Name=opt-in-status, Values=opt-in-not-required" --query "AvailabilityZones[].ZoneName" --output text)
	read -a availability_zones <<< "$availability_zones"
	for availability_zone in "${availability_zones[@]}"; do
		echo $availability_zone
		if [[ -z $(aws ec2 describe-subnets --filters "Name=availability-zone, Values=$availability_zone" "Name=default-for-az, Values=true" --output text) ]]; then
			echo "Create Default Subnet in $availability_zone"
			aws ec2 create-default-subnet --availability-zone $availability_zone

		else
			echo "Default Subnet in $availability_zone exist"
		fi
	done
	
	if [[ -z $(aws ec2 describe-security-groups --filters "Name=vpc-id, Values=$vpc_id" "Name=group-name, Values=public-ssh-and-http" --query "SecurityGroups[*].GroupName" --output text) ]]; then
		echo "Create Security Group public-ssh-and-http"
		aws ec2 create-security-group --group-name public-ssh-and-http --description "Allow SSH and HTTP access from the World" --vpc-id $vpc_id
		aws ec2 authorize-security-group-ingress --group-name public-ssh-and-http --protocol tcp --port 80 --cidr 0.0.0.0/0
		aws ec2 authorize-security-group-ingress --group-name public-ssh-and-http --protocol tcp --port 22 --cidr 0.0.0.0/0
	else
		echo "Security Group public-ssh-and-http exist"
	fi
	if [[ -z $(aws ec2 describe-security-groups --filters "Name=vpc-id, Values=$vpc_id" "Name=group-name, Values=public-ssh-http-81" --query "SecurityGroups[*].GroupName" --output text) ]]; then
                echo "Create Security Group public-ssh-http-81"
		aws ec2 create-security-group --group-name public-ssh-http-81 --description "Allow SSH, HTTP and 81/TCP access from the World" --vpc-id $vpc_id
		aws ec2 authorize-security-group-ingress --group-name public-ssh-http-81 --protocol tcp --port 80 --cidr 0.0.0.0/0
		aws ec2 authorize-security-group-ingress --group-name public-ssh-http-81 --protocol tcp --port 22 --cidr 0.0.0.0/0
		aws ec2 authorize-security-group-ingress --group-name public-ssh-http-81 --protocol tcp --port 81 --cidr 0.0.0.0/0
        else
                echo "Security Group public-ssh-http-81 exist"
        fi
	key_pairs=$(aws ec2 describe-key-pairs --query "KeyPairs[].KeyName" --output text)
	read -a key_pairs <<< "$key_pairs"
	for key in "${!keys[@]}"; do
		for key_pair in "${!key_pairs[@]}"; do
			if [[ ${keys[$key]} = ${key_pairs[$key_pair]} ]]; then
				echo "Key pair ${keys[$key]} exist"
				unset 'keys[key]'
				unset 'key_pairs[key_pair]'
				break
			fi
		done
	done
	for key in "${keys[@]}"; do
		echo "Create key pair $key"
		aws ec2 import-key-pair --key-name "$key" --public-key-material fileb://~/aws_cloud/$key.pub
	done
		
	#aws ec2 import-key-pair --key-name "student-ed25519" --public-key-material fileb://~/aws_cloud/student-ed25519.pub
	#aws ec2 import-key-pair --key-name "student-rsa" --public-key-material fileb://~/aws_cloud/student-rsa.pub

done

