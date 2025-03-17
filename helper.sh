#!/bin/bash
# Description: This file contains the helper functions for the database management system.


# Path to the Databases directory
dbPath="Databases"
# scripts to be sourced
create_Table_Script="./create_Table.sh" 
Main_Menu_Script="./Main_Menu.sh"


# The validate_name function is used to validate the database name entered by the user.
function validate_name {
    name=$1
    if [[ ! "$name" =~ ^[a-zA-Z][a-zA-Z0-9_]*$ ]]; then
        return 1
    fi
    return 0
}

# The check_DB_exists function is used to check if the database already exists.
function check_DB_exists {
    dbName=$1
    if [ -d "$dbPath/$dbName" ]; then
        return 1
    fi    
    return 0
}

# The list_DBs function is used to list all the databases in the Databases directory. The user is prompted to select a database to connect to.
function list_DBs() {
    databses=$(ls Databases/)
    selected_db=$(zenity --list --width=400 --height=300 \
    --title="List of Databases" --text="Choose a Database To Connect to:" --column="Databases" $databses)
    if [ $? -eq 1 ]; then
        DBMenu
    fi
    if [ -z $selected_db ]; then
        zenity --error --text="No Database Selected"
        list_DBs
    fi
    zenity --question --text="Do You Want To Connect To $selected_db?"
    if [ $? -eq 0 ]; then
        connect_DB $selected_db
    else
        zenity --info --text="You Have Decided Not To Connect To $selected_db"
        DBMenu
    fi
    return 0
}

# The connect_DB function is used to connect to a database. It takes the database name as input and changes the current directory to the selected database directory.
function connect_DB() {
    db=$1
    cd Databases/$db/
    zenity --info --text="Connected To $db"
    # Nenady 3la l table Menu Hena
}