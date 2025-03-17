#!/bin/bash

# Source the helper file
source helper.sh

# The create_DB function is used to create a new database. 
function create_DB {
    dbName=$(zenity --entry --title="Create DB" --text="Enter the database name:")
    if [ $? -ne 0 ]; then
        source "$Main_Menu_Script"
        return  
    fi
    if [ -z "$dbName" ]; then
        zenity --error --text="No name entered. Exiting..."
        create_DB
    fi
    dbName=$(echo "$dbName" | xargs | awk '{print tolower($0)}' | sed 's/ /_/g')
    validate_name "$dbName"
    if [ $? -ne 0 ]; then
        zenity --error --text="Invalid name $dbName. Exiting..."
        create_DB
    fi
    check_DB_exists "$dbName"
    if [ $? -ne 0 ]; then
        zenity --error --text="Database already exists. Exiting..."
        create_DB
        return
    else
        mkdir -p "$dbPath/$dbName"
        zenity --info --text="Database created successfully "
        # source "$create_Table_Script"
        return
    fi
}

create_DB
