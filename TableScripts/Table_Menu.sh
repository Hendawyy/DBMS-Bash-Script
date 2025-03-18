#!/bin/bash
source ../../helper.sh

# the Table_Menu function is used to display the main menu for the table operations.
function Table_Menu {
    choice=$(zenity --list --width=420 --height=380 \
    --title="Table Menu For $1.db" --text="Choose an Option From The Given" --column="Options" \
    "Create Table" "List Tables" "Drop Table" "Insert Into Table" "Select From Table"  "Delete From Table" "Update Table" "Disconnect From Database" "Exit")
    if [ $? -eq 1 ]; then
        cd ../..
        DBMenu
    fi

    case $choice in
        "Create Table")
            GUISQL create_Table.sh $1
            ;;
        "List Tables")
            source list_Tables.sh $1
            ;;
        "Drop Table")
            GUISQL drop_Table.sh $1
            ;;
        "Insert Into Table")
            GUISQL insert_into_Table.sh $1
            ;;
        "Select From Table")
            GUISQL select_from_Table.sh $1
            ;;
        "Delete From Table")
            GUISQL delete_from_Table.sh $1
            ;;
        "Update Table")
            GUISQL update_Table.sh $1
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