#!/bin/bash

check_dir() {
	[[ ! -d $1 ]] &&
		echo "$1 directory doens't exist, please try again.." && exit
}

while getopts :b:r:d: arg; do
	case $arg in
		b) branch=$OPTARG;;
		r) repo_path=$OPTARG;;
		d) dockerfile_path=$OPTARG;;
	esac
done

[[ $branch ]] || read -p "Please enter branch name: " branch

[[ $dockerfile_path ]] ||
	read -p "Please enter dockerfile location: " dockerfile_path
check_dir $dockerfile_path

[[ $repo_path ]] ||
	read -p "Please enter repo location: " repo_path
check_dir $repo_path

branch_path=~/$branch

[[ -d $branch_path ]] || mkdir $branch_path
#[[ -d $repo_path/$branch ]] || mkdir $repo_path/$branch

while read file; do
	filename=${file##*/}
	cp $file $branch_path/${filename^^}
	#echo mv $file ${file%/*}/${filename^^}
done <<< $(find $repo_path -type f -regex ".*.\(cbl\|cpy\|jcl\|bms\)")

#echo cp $branch_path/* $repo_path/$branch

#sed "/^COPY/ s/\s\+.*\s\+/ $branch /" $dockerfile_path/dockerfile > ~/dockerfile
sed "s/\(^COPY\)\s*\([^ ]*\)/\1 $branch/" $dockerfile_path/dockerfile > ~/dockerfile
#cp $dockerfile_path/dockerfile ~/
cd ~/

#sed -i "/^COPY/ s/\s\+.*\s\+/ $branch /" dockerfile
#cd $dockerfile_path
#docker build -t $branch:latest .
#docker run -it -p 6600:6600 -p 6680:6680 -t $branch:latest
