#!/bin/bash

source ../../helper.sh
source ../../TableScripts/GUI_Scripts/Table_Header.sh
source ../../DataRetrievalHelper.sh

function Select_TB(){
    
    dbName=$1
    tableName=$2
    DBsPath="../../Databases/$dbName"
    type=("All(*)" "Columns")
    Method=("Conditionless" "Conditioned")
    SelectedMethod=$(zenity --list --width=400 --height=600 \
    --title="Select Method" --text="Choose a Method To Select:" \
    --column="Method" "${Method[@]}")
    if [ $? -eq 1 ]; then
        zenity --info --width=400 --height=100 --title="Info" --text="Select Table Operation Cancelled"
        Table_Menu $dbName
    fi
    if [ -z $SelectedMethod ]; then
        zenity --error --text="No Method Selected"
        Select_TB $dbName
    fi
    SelectedType=$(zenity --list --width=400 --height=600 \
    --title="Select Type" --text="Choose a Type To Select:" \
    --column="Type" "${type[@]}")
    if [ $? -eq 1 ]; then
        zenity --info --width=400 --height=100 --title="Info" --text="Select Table Operation Cancelled"
        Table_Menu $dbName
    fi
    if [ -z $SelectedType ]; then
        zenity --error --text="No Type Selected"
        Select_TB $dbName
    fi
    if [ $SelectedMethod == "Conditioned" ]; then
        Select_With_Condition $SelectedType $dbName $tableName
    elif [ $SelectedMethod == "Conditionless" ]; then
        Select_Without_Condition $SelectedType $dbName $tableName
    else
        zenity --error --text="Invalid Method"
        Select_TB $dbName
    fi
}

Select_TB $1 $2




