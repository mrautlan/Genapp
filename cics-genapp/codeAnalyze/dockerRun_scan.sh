#!/bin/bash

print_instructions() {
	cat <<- EOF
		Instructions about how to create another project in WA container:
		<your text here>

		Instructions about how to start and stop the server:
		<your text here>

		Instructions about how to scan:
		<your text here>
	EOF
}

while getopts :b:r:d: arg; do
	case $arg in
		b) branch=$OPTARG;;
		r) repo_path=$OPTARG;;
		d) dockerfile_path=$OPTARG;;
	esac
done

[[ $branch ]] || read -p "Please enter branch name: " branch

[[ $repo_path ]] ||
	read -p "Please enter repo location: " repo_path
[[ ! -d $repo_path ]] &&
	echo "$repo_path directory doens't exist, please try again.." && exit

branch_path=~/$branch

[[ -d $branch_path ]] &&
	rm $branch_path/* || mkdir $branch_path

while read file; do
	filename=${file##*/}
	cp $file $branch_path/${filename^^}
done <<< $(find $repo_path -type f -regex ".*.\(cbl\|cpy\|jcl\|bms\)")

read -p 'Do you want to run a WA container? [Y/n] ' run_container

wazianalyze="ibmcom/wazianalyze:1.4.0"
docker_command="docker run -v $HOME/$branch:/home/wazianalyze/data/project/source -it --rm -p 5000:5000 -p 4680:4680 --name $branch $wazianalyze"

if [[ $run_container == [Nn]* ]]; then
	echo "Run the following command to start the container:"
	echo "$docker_command"
	print_instructions
else
	print_instructions
	$docker_command
fi
