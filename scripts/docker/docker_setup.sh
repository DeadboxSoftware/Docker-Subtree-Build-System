if [ "$OSTYPE" == "darwin21" ]; then
    echo "..."
elif [ "$OSTYPE" == "linux-gnu" ]; then
    /bin/python3 'scripts/buildingtemplateenv.py' core &&
    /bin/python3 'scripts/buildingtemplateenv.py' containers &&
    /bin/python3 'scripts/buildingtemplateenv.py' secondary &&
    fix_folder_perms &&
    (source .env && docker network create --subnet $DOCKER_NETWORK_IP $NETWORK_NAME) #  || true && docker compose build && docker compose up --force-recreate 
    echo "---------------------------------"
    echo "Configs configured successfully"
    echo "Network $NETWORK_NAME $DOCKER_NETWORK_IP - Successfully Setup"
    echo "---------------------------------"
    echo "Run - \`docker compose up --build\`"

elif [ "$OSTYPE" == "msys" ]; then
    python 'scripts/buildingtemplateenv.py' core &&
    python 'scripts/buildingtemplateenv.py' containers &&
    python 'scripts/buildingtemplateenv.py' secondary &&
    fix_folder_perms &&
    (source .env && docker network create --subnet $DOCKER_NETWORK_IP $NETWORK_NAME) #  || true && docker compose build && docker compose up --force-recreate 
    echo "---------------------------------"
    echo "Configs configured successfully"
    echo "Network $NETWORK_NAME $DOCKER_NETWORK_IP - Successfully Setup"
    echo "---------------------------------"
    echo "Run - \`./docker.sh entrypoint_fix\`"
    echo "Run - \`docker compose up --build\`"
else
    echo ""
fi