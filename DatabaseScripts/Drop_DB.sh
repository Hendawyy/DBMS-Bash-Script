#!/bin/bash
# Description: This file contains the function to drop a database.
source DatabaseScripts/DB_Menu.sh
# The Drop_DB function is used to drop a database in the Databases directory.
function Drop_DB(){
    databses=$(ls Databases/)
    selected_db=$(zenity --list --width=400 --height=300 \
    --title="List of Databases" --text="Choose a Database To Drop:" --column="Databases" $databses)
    if [ $? -eq 1 ]; then
        zenity --info --text="You Have Decided Not To Drop Any Database"
        DBMenu
    fi
    if [ -z $selected_db ]; then
        zenity --error --text="No Database Selected"
        Drop_DB
    fi
    zenity --question --text="Do You Want To Drop $selected_db?"
    if [ $? -eq 0 ]; then
        rm -r Databases/$selected_db
        zenity --info --text="$selected_db Dropped Successfully"
        DBMenu
    else
        zenity --info --text="You Have Decided Not To Drop $selected_db"
        DBMenu
    fi
}

Drop_DB