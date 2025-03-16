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
    else
        return 0
    fi    
}