#!/bin/bash
source ../../helper.sh

GUI_Scripts_path="../../TableScripts/GUI_Scripts" 
Database_Scripts_Path="../../DatabaseScripts"
source $Database_Scripts_Path/DB_Menu.sh 

echo "from TAble_operations $(pwd)"
echo $(ls "$GUI_Scripts_path")

# Table operations menu
function table_operations {
    choice=$(zenity --list --width=420 --height=380 \
    --title="Table Operations for $1" --text="Choose an Option From The Given" --column="Options" \
    "Drop Table" "Delete From Table" "Insert Into Table" "Select From Table" "Update Table" "Disconnect From Database" "Exit")

    if [ $? -eq 1 ]; then
        cd ../..
        DBMenu  
    fi

    case $choice in
        "Drop Table")
            GUISQL "$GUI_Scripts_path/drop_Table.sh" "$1"
            ;;
        "Delete From Table")
            GUISQL "$GUI_Scripts_path/delete_from_table.sh" "$1"
            ;;
        "Insert Into Table")
            GUISQL "$GUI_Scripts_path/insert_into_Table.sh" "$1"
            ;;
        "Select From Table")
            GUISQL "$GUI_Scripts_path/select_from_Table.sh" "$1"
            ;;
        "Update Table")
            GUISQL "$GUI_Scripts_path/update_Table.sh" "$1"
            ;;
        "Disconnect From Database")
            cd ../..
            DBMenu
            ;;
        "Exit")
            echo "Thanks For Using Our Database Engine"
            echo "Goodbye!"
            exit
            ;;
        *)
            zenity --error --text="Invalid Option. Please try again."
            table_operations "$1"
            ;;
    esac
}

table_operations "$1"
