#!/bin/bash
# Description: This file contains the helper functions for the database management system.


# Path to the Databases directory
dbPath="../Databases"
# scripts to be sourced
create_Table_Script="./create_Table.sh" 
Main_Menu_Script="./Main_Menu.sh"



# The create_DB function is used to create a new database. It takes the database name as input from the user and creates a new directory with the same name in the Databases directory.
# If the database name is invalid or already exists, an error message is displayed and the user is prompted to enter a valid name.
# If the database is created successfully, the create_Table.sh script is called to create a new table in the database.  
# The create Table script is sourced to create a new table in the database.
function create_DB {
    while true; do
        dbName=$(zenity --entry --title="Create DB" --text="Enter the database name:")
        if [ $? -ne 0 ]; then
            source "$Main_Menu_Script"
            return  
        fi
        if [ -z "$dbName" ]; then
            zenity --error --text="No name entered. Exiting..."
            continue
        fi
        dbName=$(echo "$dbName" | xargs | awk '{print tolower($0)}' | sed 's/ /_/g')
        if [[ "$dbName" =~ [^a-zA-Z0-9_] ]]; then
            zenity --error --text="Invalid database name. Please enter a valid name."
            continue
        fi

        if [ -d "$dbPath/$dbName" ]; then
            zenity --error --text="Database already exists. Exiting..."
            continue
        else
            mkdir -p "$dbPath/$dbName"
            zenity --info --text="Database created successfully "
            source "$create_Table_Script"
            return
        fi
    done
}