#!/bin/bash


# Absolute path to the directory that contains "cron.sh"
home='/home/nvidia/remotelab/check_rsv'
source $home/utils.sh

registry='uranium.snu.ac.kr:5000'
default_image='openlab'
default_tag='default'
image_deploy_sh=$home/image_deploy.sh
soon=$home/.soon
running=$home/.running
save_image=${home}/.image
str=''

# if there is a running user now, don't execute this script.
while read line
do
	str=$line
done < $running

if [[ $str == 'nobody' ]]; then
	# debug
	#echo "somebody will be started soon"
	str=''
else
	# debug
	#echo "$str is running a container"
	exit
fi 

# debug needed
curl uranium.snu.ac.kr:7780/soon > $soon

while read line
do
	str=$line
done < $soon



infos=($(echo $str | tr '_' "\n"))

# if soon output format changes, indexing should
# be changed accordingly.
user=${infos[5]}
sub_user=${user//@/.}
start=${infos[6]}
end=${infos[7]}
pwd=${infos[8]}
selImage=${infos[9]}

if [[ $start == 'next' ]]; then
	exit
fi

cur_d=$(date +'%m%d')
cur_t=$(date +'%H:%M')

echo "[${cur_d}-${cur_t}] start: $start, end: $end, $user, $pwd, $selImage"

cur_t_=$(plus_minute $cur_t 1)


if [[ $cur_t_ == $start ]]; then
	#debug
	#echo "${cur_t_}=${start}"

	# if selImage is default, pull openlab:default
	if [[ $selImage == $default_tag ]]; then
		image="${registry}/${default_image}:${default_tag}"
		save_as="${registry}/${sub_user}:${default_tag}_${cur_d}"
	else
	# if not, pull user's image
		image="${registry}/${sub_user}:${selImage}"
		save_as="${registry}/${sub_user}:${selImage}_${cur_d}"
	fi

	echo "${image} will be ${save_as}"	

	# set the running user 
	echo $sub_user > $running

	echo ${save_as} > ${save_image}
	at ${end} -f ${image_deploy_sh}

	docker run -dit --rm --name remotelab --runtime nvidia --privileged --env=”QT_X11_NO_MITSHM=1” \
     --device=/dev/video0:/dev/video0  -e DISPLAY=$DISPLAY -v /tmp/.X11-unix:/tmp/.X11-unix \
     -p 6080:80 -p 5900:5900 -p 2368:2368/udp -e VNC_PASSWORD=$pwd \
	-p 6081:443 -e SSL_PORT=443 -v ${home}/ssl:/etc/nginx/ssl -v /dev/shm:/dev/shm \
	--entrypoint="/startup.sh" \
     $image

fi



