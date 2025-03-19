#!/bin/bash
# exec 2>/dev/null
# Description: This file contains the helper functions for the database management system.
# Path to the Databases directory
dbPath="Databases"
# scripts to be sourced
Table_Menu_Script="../../TableScripts/Table_Menu.sh"
Database_Scripts_Path="../../DatabaseScripts"
SQL_Scripts_Path="../../TableScripts/SQL_Scripts"
GUI_Scripts_path="../../TableScripts/GUI_Scripts" 

source $Database_Scripts_Path/DB_Menu.sh 2>/dev/null
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
# The check_TB_exists function is used to check if the table already exists.
function check_TB_exists {
    dbName=$1
    tbName=$2
    if [ -d "$dbPath/$dbName/$tbName" ]; then
        return 1
    fi
    return 0
}
# The list_DBs function is used to list all the databases in the Databases directory. The user is prompted to select a database to connect to.
function list_DBs() {
    databses=$(ls Databases/)
    selected_db=$(zenity --list --width=400 --height=600 \
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
    source $Table_Menu_Script $db
}

# The GUISQL function is used to prompt the user to choose between GUI and SQL mode for table operations.
function GUISQL(){
    script_name=$1
    db_name=$2
    type=$(zenity --list --width=420 --height=380 \
    --title="Do you want To Use GUI or SQL" --text="Choose an Option From The Given" --column="Options" \
    "GUI" "SQL")
    if [ $? -eq 1 ]; then
        Table_Menu $db_name
    fi

    if [[ "$type" == "GUI" ]]; then
        source $GUI_Scripts_path/$script_name $db_name
    elif [[ "$type" == "SQL" ]]; then
        SQL_Mode "$script_name" "$db_name"
    else
        zenity --error --text="Invalid Option"
        GUISQL "$script_name" "$db_name"
    fi
}

# The SQL_Mode function is used to call the SQL scripts for table operations.
function SQL_Mode(){
    script_name=$1
    db_name=$2

    case "$script_name" in
        "create_Table.sh")
            $SQL_Scripts_Path/SQLCreateTable.sh "$db_name"
            ;;
        "drop_Table.sh")
            $SQL_Scripts_Path/SQLDropTable "$db_name"
            ;;
        "insert_into_Table.sh")
            $SQL_Scripts_Path/SQLInsertIntoTable.sh "$db_name"
            ;;
        "select_from_Table.sh")
            $SQL_Scripts_Path/SQLSelectFromTable.sh "$db_name"
            ;;
        "delete_from_Table.sh")
            $SQL_Scripts_Path/SQLDeleteFromTable.sh "$db_name"
            ;;
        "update_Table.sh")
            $SQL_Scripts_Path/SQLUpdateTable.sh "$db_name"
            ;;
        *)
            zenity --error --text="Invalid Option"
            Table_Menu $db_name
            ;;
    esac
}
