if [ "$OSTYPE" == "darwin21" ]; then
    /bin/python3 'scripts/buildingtemplateenv.py' core &&
    /bin/python3 'scripts/buildingtemplateenv.py' containers &&
    /bin/python3 'scripts/buildingtemplateenv.py' secondary &&
    fix_folder_perms
elif [ "$OSTYPE" == "linux-gnu" ]; then
    /bin/python3 'scripts/buildingtemplateenv.py' core &&
    /bin/python3 'scripts/buildingtemplateenv.py' containers &&
    /bin/python3 'scripts/buildingtemplateenv.py' secondary &&
    fix_folder_perms
elif [ "$OSTYPE" == "msys" ]; then
    /bin/python3 'scripts/buildingtemplateenv.py' core &&
    /bin/python3 'scripts/buildingtemplateenv.py' containers &&
    /bin/python3 'scripts/buildingtemplateenv.py' secondary &&
    fix_folder_perms
else
    python 'scripts/buildingtemplateenv.py' setupenv
fi