#!/bin/bash

source ../../helper.sh
GUI_Scripts_path="../../TableScripts/GUI_Scripts"
Database_Scripts_Path="../../DatabaseScripts"
source $Database_Scripts_Path/DB_Menu.sh 


# The list_Tables function is used to list all the tables in the selected database.
function list_Tables {

    db_name=$1
    if [[ -z "$db_name" ]]; then
        zenity --error --text="Error: No database name provided!"
        Table_Menu $db_name
    fi

    db_path="../$db_name/"

    if [[ ! -d "$db_path" ]]; then
        zenity --error --text="Error: Database '$db_name' does not exist!"
        Table_Menu $db_name
    fi

    tables=$(ls "$db_path")

    if [[ -z "$tables" ]]; then
        zenity --info --text="No tables found in database '$db_name'."
        Table_Menu $db_name 
    fi

    selected_table=$(zenity --list --width=400 --height=600 \
        --title="List of Tables" --text="Choose a Table To Perform Operations on:" \
        --column="Tables" $tables)

    if [[ -z "$selected_table" ]]; then
        zenity --info --text="No table selected."
        Table_Menu $db_name
    else
        zenity --info --text="Selected table: $selected_table"
        source $GUI_Scripts_path/table_Operations.sh $selected_table $db_name
    fi

}

list_Tables $1