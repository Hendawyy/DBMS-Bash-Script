#!/bin/bash
source ../../helper.sh

GUI_Scripts_path="../../TableScripts/GUI_Scripts" 
Database_Scripts_Path="../../DatabaseScripts"
source $Database_Scripts_Path/DB_Menu.sh 

# the Table_Menu function is used to display the main menu for the table operations.
function Table_Menu {
    choice=$(zenity --list --width=420 --height=380 \
    --title="Table Menu For $1.db" --text="Choose an Option From The Given" --column="Options" \
    "Create Table" "List Tables" "Disconnect From Database" "Exit")
    if [ $? -eq 1 ]; then
        cd ../..
        DBMenu
    fi

    case $choice in
        "Create Table")
            GUI create_Table.sh $1
            ;;
        "List Tables")
            source $GUI_Scripts_path/list_Tables.sh $1
            ;;
        "Disconnect From Database")
            cd ../..
            DBMenu
            ;;
        "Exit")
            echo "Thanks For Using Our Database Engine"
            echo "Good Bye"
            exit
            ;;
        *)
            zenity --error --text="Invalid Option. Please try again."
            Table_Menu $1
            ;;

    esac
}

Table_Menu $1