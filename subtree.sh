# PULL FROM: master
# PUSH TO: docker

# Below are listed repositories
# If you want to ignore a repo 
# Use ! before a name
# e.g "!repo-name"

declare -a folders=(
	"nodeapp/app"
	"ignorethis/app"
)

declare -a repo=(
	"git@github.com:Backshift/Node-App-Toolset.git"
	"git@github.com:Backshift/Node-App-Toolset.git"
)

declare -a branch=(
	"main"
	"main"
)

declare -a names=(
	"nodeapp"
	"!ignorethis" # ! => to not include repo
)


function repo_selection(){

	echo ""
	echo "Select a repo to $1:"
	echo ""
	for i in "${!folders[@]}"
	do
		echo "[${i}] ${names[$i]}: ${folders[$i]}"
		# git subtree add ${subtrees[$i]}
		# echo $i
	done

	echo ""
	unset number
	until [[ $number == +([0-9]) ]] ; do
	    read -r -p "please enter a number: " number
	done
	# echo $((number))

	return $number

}

# ${arr[0]}

if [ -z $1 ]
then
	printf """subtree.sh                 
Commands:
* push => (args: <repo_name>)
* pull => (args: <repo_name>)
* add => (args: <repo_name>)
* pull_all => pulls all repos except ignored with !repo_name
* push_all => push all repos except ignored with !repo_name
* add_all => TBD
--------
"
elif [ $1 == 'add' ]
then

	if [ "$2" ]; then
		for ((i=0; i<"${#names[@]}"; i++)); do
			if [ "${names[i]:0:1}" != "!" ] && [ "$2" == "${names[i]}" ]; then
				git subtree add --prefix=${folders[i]} ${repo[i]} ${branch[i]} --squash
			fi
		done
	else
		repo_selection $1
		res=$?
		git subtree add --prefix=${folders[$res]} ${repo[$res]} ${branch[$res]}
	fi

elif [ $1 == 'pull' ]
then

	if [ "$2" ]; then
		for ((i=0; i<"${#names[@]}"; i++)); do
			if [ "${names[i]:0:1}" != "!" ] && [ "$2" == "${names[i]}" ]; then
				# git subtree add --prefix=${folders[i]} ${repo[i]} ${branch[i]} &&
				git subtree pull --prefix=${folders[$i]} ${repo[$i]} ${branch[$i]} --squash
				# SQUASH IF NEEDED => 
			fi
		done
	else
		repo_selection $1
		res=$?
		git subtree add --prefix=${folders[$res]} ${repo[$res]} ${branch[$res]}
		git subtree pull --prefix=${folders[$res]} ${repo[$res]} ${branch[$res]} --squash --no-commit
	fi

elif [ $1 == 'push' ]
then

	if [ "$2" ]; then
		for ((i=0; i<"${#names[@]}"; i++)); do
			if [ "${names[i]:0:1}" != "!" ] && [ "$2" == "${names[i]}" ]; then
				git subtree push --prefix=${folders[$i]} ${repo[$i]} ${branch[$i]}
			fi
		done
	else
		repo_selection $1
		res=$?
		git subtree push --prefix=${folders[$res]} ${repo[$res]} ${branch[$res]}
	fi
elif [ $1 == 'pull_all' ]
then

	for ((i=0; i<"${#folders[@]}"; i++)); do
		if [ "${names[i]:0:1}" != "!" ]; then
			# echo "test"
	        # Create the folder if it doesn't exist
	        # mkdir -p "${folders[i]}"
			git subtree add --prefix=${folders[i]} ${repo[i]} ${branch[i]}
			git subtree pull --prefix=${folders[i]} ${repo[i]} ${branch[i]} --squash
		fi
	done

elif [ $1 == 'push_all' ]
then

	for ((i=0; i<"${#folders[@]}"; i++)); do
		if [ "${names[i]:0:1}" != "!" ]; then
			git subtree push --prefix=${folders[i]} ${repo[i]} ${branch[i]}
		fi
	done


else
	echo "Invalid command..."
fi