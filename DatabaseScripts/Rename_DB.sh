#!/bin/bash
# Description: This file contains the function to rename a database.
source helper.sh
# The Rename_DB function is used to rename a database in the Databases directory.
function Rename_DB(){
    databses=$(ls Databases/)
    selected_db=$(zenity --list --width=400 --height=300 \
    --title="List of Databases" --text="Choose a Database To Rename:" --column="Databases" $databses)
    if [ $? -eq 1 ]; then
        zenity --info --text="You Have Decided Not To Rename Any Database"
        DBMenu
    fi
    if [ -z $selected_db ]; then
        zenity --error --text="No Database Selected"
        Rename_DB
    fi
    new_name=$(zenity --entry --width=300 --title="Rename Database" --text="Enter New Name For $selected_db")
    new_name=$(echo "$new_name" | xargs | awk '{print tolower($0)}')
    validate_name "$new_name"
    if [ $? -ne 0 ]; then
        zenity --error --text="Invalid name $new_name. Exiting..."
        Rename_DB
    fi
    if [ $? -eq 1 ]; then
        zenity --info --text="You Have Decided Not To Rename $selected_db"
        DBMenu
    fi
    if [ -z $new_name ]; then
        zenity --error --text="No Name Entered"
        Rename_DB
    fi
    check_DB_exists "$new_name"
    if [ $? -ne 0 ]; then
        zenity --error --text="Database $new_name Already Exists"
        Rename_DB
    fi
    mv Databases/$selected_db Databases/$new_name
    zenity --info --text="$selected_db Renamed To $new_name Successfully"
    DBMenu
}

Rename_DB