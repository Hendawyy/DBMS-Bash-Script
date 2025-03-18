#!/bin/bash
source DatabaseScripts/DB_Menu.sh
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