#!/bin/bash
# Description: This file contains the main functions for the database management system and is the entrypoint for the application.
# The DBMenu function is used to display the main menu of the database engine. The user is prompted to choose an option from the given list of options.
function DBMenu {
    while true; do
    choice=$(zenity --list --width=400 --height=300 \
    --title="DB Engine Main Menu" --text="Choose an Option From The Given" --column="Options" \
    "Create DB" "List DB" "Rename DB" "Drop DB" "Connect To a DB" "Exit")
    if [ $? -eq 1 ]; then
        echo "Thanks For Using Our Database Engine"
        echo "Good Bye"
        exit
    fi
    scripts="DatabaseScripts"
    case $choice in
        "Create DB")
            source $scripts/Create_DB.sh
            ;;
        "List DB")
            source $scripts/List_DB.sh
            ;;
        "Rename DB")
            source $scripts/Rename_DB.sh
            ;;
        "Drop DB")
            source $scripts/Drop_DB.sh
            ;;
        "Connect To a DB")
            source $scripts/Connect_DB.sh
            ;;
        "Exit")
            echo "Thanks For Using Our Database Engine"
            echo "Good Bye"
            exit
            ;;
        *)
            zenity --error --text="Invalid Option"
            ;;
    esac
    done
}
# The StartDB function is used to display a welcome message to the user and call the DBMenu function to display the main menu of the database engine.
function StartDB {
    zenity --text-info --title="Wlecome To Our DB Engine" --filename="DB.txt" --width=440 --height=580
    if [ $? -eq 1 ]; then 
        echo "Thanks For Using Our Database Engine"
        echo "Good Bye"
        exit
    fi
    DBMenu
}   


StartDB