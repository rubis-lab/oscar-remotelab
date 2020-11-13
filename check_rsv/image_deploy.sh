#!/bin/bash

# This script is executed at reservation finish time
# this will change running status to 'nobody',  commit 
# the docker container as new name, and push to the registry
# the name to be saved is stored in '.image' file

# Absolute path to the directory that contains "image_deploy.sh"
abs=$PWD
home='$abs/check_rsv'

name='remotelab'
running=$home/.running
status='nobody'
image=$home/.image

cur_d=$(date +'%m:%d')
cur_t=$(date +'%H:%M')

echo "[${cur_d}-${cur_t}]"

if [ -f $image ]; then
	while read line
	do
		save_as=$line
	done < $image
fi

rm $image
echo $status > $running

docker commit $name $save_as && \
docker stop remotelab
docker push $save_as
