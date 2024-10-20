function perform_backup(){
    date=$(date +"%Y%m%d")
    full_str=$date"$1"
    echo $1
    read -p "Give the backup a name (Default is deadbox_product_dbbackup_)" -r
    if [[ -z "$REPLY" ]]; then
        s="deadbox_product_dbbackup_"
    else
        s="$REPLY"
    fi

    if [[ "$OSTYPE" == "msys" ]]; then
        cd postgres
        "C://Program Files/7-Zip/7z.exe" a -t7z "_BACKUPS/$s$date.7z" "data" -mx=7
    fi

    if [[ "$OSTYPE" == "linux-gnu" ]]; then
        echo "using linux..."
        cd ./postgres/
        7z a -t7z "./_BACKUPS/$s$date.7z" "./data" -mx=7
    fi
}

function perform_restore(){
    # Backup or restore 7z folder containing database export
    yourfilenames=$(ls ./postgres/_BACKUPS/*.7z)
    replace=""
    arr=()
    full_arr=()
    for eachfile in $yourfilenames
    do
        arr+=(${eachfile//"./postgres/_BACKUPS/"/$replace})
        full_arr+=(${eachfile})
    done
    printf """${BGreen}Backup & Restore Zips \n\n${NC}"""
    for key in "${!arr[@]}"
    do
        echo "$key => Value is ${arr[$key]}"
    done
    read -p "Type the number you want to use: " -r
    printf """\n\n"""
    full_path="${full_arr[$REPLY]}"

    if [[ -z "$full_path" ]]; then
        # Empty var
        echo "Please select a valid Number..."
    else
        echo $full_path
        
        if [[ "$OSTYPE" == "msys" ]]; then
            "C://Program Files/7-Zip/7z.exe" x -o./postgres/ $full_path
        fi

        if [[ "$OSTYPE" == "linux-gnu" ]]; then
            7z x -o./postgres/ $full_path
        fi
    fi
}


if [ $1 == "backup" ]; then
    perform_backup
elif [ $1 == "restore" ]; then
    perform_restore
fi