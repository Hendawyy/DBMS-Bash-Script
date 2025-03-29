#!/bin/bash
source ../../helper.sh

function drop_sql() {
    dbName=$1
    shift
    sql_command="$*"

    DBsPath="../../Databases/$dbName"
    tables=($(ls "$DBsPath"))

    sql_command=$(echo "$sql_command" | tr -s " " | xargs)
    read -ra sql_parts <<< "$sql_command"

    table_name=${sql_parts[2]}

    if [ ! -d "$DBsPath/$table_name" ]; then
        # clear
        echo "Table '$table_name' does not exist in database '$dbName'."
        source ../../TableScripts/Table_Menu.sh "$dbName"
    fi

    rm -rf "$DBsPath/$table_name"

    echo "Table '$table_name' has been successfully deleted."
}

drop_sql $1 $2
