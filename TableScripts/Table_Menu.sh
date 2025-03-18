#!/bin/bash

# the Table_Menu function is used to display the main menu for the table operations.
function Table_Menu {
    choice=$(zenity --list --width=420 --height=380 \
    --title="Table Menu For $1.db" --text="Choose an Option From The Given" --column="Options" \
    "Create Table" "List Tables" "Drop Table" "Insert Into Table" "Select From Table"  "Delete From Table" "Update Table" "Disconnect From Database" "Exit")
    if [ $? -eq 1 ]; then
        DBMenu
    fi

    case $choice in
        "Create Table")
            source create_Table.sh
            ;;
        "List Tables")
            source list_Tables.sh
            ;;
        "Drop Table")
            source drop_Table.sh
            ;;
        "Insert Into Table")
            source insert_into_Table.sh
            ;;
        "Select From Table")
            source select_from_Table.sh
            ;;
        "Delete From Table")
            source delete_from_Table.sh
            ;;
        "Update Table")
            source update_Table.sh
            ;;
        "Disconnect From Database")
            DBMenu
            ;;
        "Exit")
            echo "Thanks For Using Our Database Engine"
            echo "Good Bye"
            exit
            ;;
        *)
            zenity --error --text="Invalid Option. Please try again."
            Table_Menu
            ;;

    esac
}

Table_Menu $1