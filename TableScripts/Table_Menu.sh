#!/bin/bash

# the Table_Menu function is used to display the main menu for the table operations.
function Table_Menu {
    choice=$(zenity --list --width=400 --height=300 \
    --title="DB Engine Main Menu" --text="Choose an Option From The Given" --column="Options" \
    "Create Table" "List Tables" "Drop Table" "Insert Into Table" "Select From Table"  "Delete From Table" "Update Table" "Disconnect From Database" "Exit")
    if [ $? -eq 1 ]; then
        echo "Thanks For Using Our Database Engine"
        echo "Good Bye"
        exit
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
            source Main_Menu.sh
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

Table_Menu