source .env
echo "$OSTYPE"

RED='\033[0;31m'
NC='\033[0m' # No Color
BGreen='\033[1;32m'

function choose_docker_conf(){
    # Backup or restore zip folder containing database export
    if [ "$OSTYPE" == "linux-gnu" ]; then
        yourfilenames=`ls ./templates/docker/*.yml`
    else
        yourfilenames=`ls ./templates/docker/*.yml`
    fi
    replace=""
    arr=()
    full_arr=()
    for eachfile in $yourfilenames
    do
    arr+=(${eachfile//"./templates/docker/"/$replace})
    full_arr+=(${eachfile})
    done
	printf """${BGreen}Docker config select \n\n${NC}"""
    for key in "${!arr[@]}"
    do
    echo "$key => Value is ${arr[$key]}"
    done
    read -p "Type NO you want to use " -r # -n 1
    printf """\n\n"""
    full_path="${full_arr[$REPLY]}"


    if [[ -z "$full_path" ]]; then
        echo "Please select a valid Number..."
    else
        echo $full_path
        rm ./docker-compose.yml
        cp $full_path ./docker-compose.yml
    fi
}

if [ -z $1 ]
then
	printf """${BGreen}Docker.sh                 
    ${RED}
Essential Commands:
* setup => Primary setup script
* restore => Restore Database files
* backup => Backup current database files
* certs => Generates certs in `/certs` directory
--------
Docker:
* compose => Use a different docker compose file
--------
Build Options:
* build 
* build_nocache => Builds with nocache
* build_network => Builds docker network
--------
Config Options:
* build_configs => Builds all template files
* env => Builds out env files
* folder_perms => Changes folder permissions to correct docker perms
--------
Database:
* update_seq => Updates sequence on all database tables
-------- 
Misc:
* update_sql_pword => Updates sql password to stored env pword
* clean => Cleans all project files from setup
* entrypoint_fix => For windows systems change entrypoints so it works on linux
${NC}
    "
elif [ $1 == 'build' ]
then
	#
    docker compose build
    docker compose up
elif [ $1 == 'build_nocache' ]
then
    docker compose build --no-cache
    docker compose up
elif [ $1 == 'build_network' ]
then
    # docker network create docker_subtree
    docker network create --subnet $DOCKER_NETWORK_IP $NETWORK_NAME
elif [ $1 == 'setup' ]
then
    bash scripts/docker/docker_setup.sh
elif [ $1 == 'build_configs' ]; then
    bash scripts/docker/docker_build_configs.sh
elif [ $1 == 'restore' ]
then
    rm -r ./postgres/data
    bash "scripts/db_backup_restore.sh" restore
elif [ $1 == 'backup' ]
then
    bash "scripts/db_backup_restore.sh" backup
elif [ $1 == 'compose' ]; then
    choose_docker_conf
elif [ $1 == 'folder_perms' ]; then
    fix_folder_perms
elif [ $1 == 'clean' ]; then
    if [ "$OSTYPE" == "darwin21" ]; then
        /bin/python3 'scripts/buildingtemplateenv.py' clean
    elif [ "$OSTYPE" == "linux-gnu" ]; then
        /bin/python3 'scripts/buildingtemplateenv.py' clean
    elif [ "$OSTYPE" == "msys" ]; then
        python 'scripts/buildingtemplateenv.py' clean
    else
        python 'scripts/buildingtemplateenv.py' clean
    fi
elif [ $1 == 'certs' ]; then
    folder="./certs"
    # Check if the folder exists, if not, create it
    if [ ! -d "$folder" ]; then
        mkdir -p "$folder"
    fi
    # Generate the private key
    openssl genpkey -algorithm RSA -out "$folder/key.pem" -pkeyopt rsa_keygen_bits:2048
    # Generate the certificate signing request (CSR)
    openssl req -new -key "$folder/key.pem" -out "$folder/csr.pem"
    # Generate the certificate, valid for 365 days
    openssl x509 -req -days 365 -in "$folder/csr.pem" -signkey "$folder/key.pem" -out "$folder/crt.pem"
    # openssl genpkey -algorithm RSA -out certs/key.pem -pkeyopt rsa_keygen_bits:2048
    # openssl req -new -key certs/key.pem -out certs/csr.pem
    # openssl x509 -req -days 365 -in certs/csr.pem -signkey certs/key.pem -out certs/crt.pem
elif [ $1 == "entrypoint_fix" ]; then
    if [ -z "$2" ]; then
        echo "Please put in a entrypoint for fixing IE \`nodeapp/entrypoint.sh\`"
        exit 1
    fi
    dos2unix $2 # 
elif [ $1 == "update_sql_pword" ]; then
    bash "./scripts/update_sql_pword.sh" 
else
	echo "No command found..."
fi
