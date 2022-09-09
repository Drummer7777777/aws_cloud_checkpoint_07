#!/bin/bash

echo $(aws ec2 describe-regions --all-regions --query "Regions[?OptInStatus  == 'opt-in-not-required'].RegionName" --output text) | sed 's/ /\n/g' > regions_allowed.conf


