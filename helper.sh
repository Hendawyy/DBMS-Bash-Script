#!/bin/bash
# Description: This file contains the helper functions for the database management system.


# Path to the Databases directory
dbPath="Databases"
# scripts to be sourced
create_Table_Script="./create_Table.sh" 
Main_Menu_Script="./Main_Menu.sh"



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
    if [ -d "$dbPath/$dbName" ]; then
        zenity --error --text="Database already exists. Exiting..."
        create_DB
    else
        mkdir -p "$dbPath/$dbName"
        zenity --info --text="Database created successfully "
        source "$create_Table_Script"
        return
    fi
}

# The validate_name function is used to validate the database name entered by the user.
function validate_name {
    dbName=$1
    if [[ ! "$dbName" =~ ^[a-zA-Z][a-zA-Z0-9_]*$ ]]; then
        zenity --error --text="Invalid database name. Must start with a letter and contain only letters, numbers, and underscores."
        create_DB  
    fi
}