#!/bin/bash

bucket="cec-"$(aws sts get-caller-identity --query Account --output text)"-j2"
aws s3 cp /home/drummer/aws_cloud/checkpoint_07/amazon_launch_script s3://$bucket/user-data/checkpoint_07/amazon_launch_script
aws s3 cp /home/drummer/aws_cloud/checkpoint_07/ubuntu_launch_script2 s3://$bucket/user-data/checkpoint_07/ubuntu_launch_script2
#aws s3 cp /home/drummer/aws_cloud/checkpoint_06/assume_role_and_update_ip.service s3://$bucket/assume_role_and_update_ip.service/assume_role_and_update_ip.service
#aws s3 cp /home/drummer/aws_cloud/checkpoint_06/araui s3://$bucket/assume_role_and_update_ip.service/araui
#aws s3 cp /home/drummer/aws_cloud/checkpoint_06/resource_record_set.json s3://$bucket/route53/resource_record_set.json

