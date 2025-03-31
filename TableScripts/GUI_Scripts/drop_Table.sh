#!/bin/bash
source ../../helper.sh
Database_Scripts_Path="../../DatabaseScripts"
source $Database_Scripts_Path/DB_Menu.sh 

# The drop_Tables function is used to delete a table from the selected database.
function drop_Tables {

    db_name=$1
    table_name=$2

    if [[ -z "$table_name" ]]; then
        zenity --error --text="Error: No table name provided!"
        Table_Menu "../"
        exit 1
    fi

    rm -r "$table_name"

    zenity --info --text="Table '$table_name' has been dropped successfully."

    Table_Menu "$db_name"
}

drop_Tables "$1" "$2"