#!/bin/bash
source ../../helper.sh

function Filter_And_Delete_Rows() {
    dbName=$1
    tableName=$2
    cat $db
    Column_Names=$(awk -F: 'NR>3 {print $1}' "$tableName/$tableName.md")

    ColumnCondition=$(zenity --list --width=400 --height=600 \
    --title="Columns in $tableName" --text="Choose a Column To Filter On:" \
    --column="Columns" $Column_Names)

    if [ $? -eq 1 ] || [ -z "$ColumnCondition" ]; then
        zenity --error --text="Operation Cancelled or No Column Selected"
        source ../../TableScripts/Table_Menu.sh "$dbName"
        return
    fi

    DataTypeCondColumn=$(awk -F: -v colName="$ColumnCondition" 'NR>3 {if($1==colName) print $2}' "$tableName/$tableName.md")

    if [[ "$DataTypeCondColumn" == "ID--Int--Auto--Inc." || "$DataTypeCondColumn" == "INT" || "$DataTypeCondColumn" == "Double" || "$DataTypeCondColumn" == "Date" || "$DataTypeCondColumn" == "current_timestamp" ]]; then
        operators=("==" "!=" ">" "<" ">=" "<=")
    else
        operators=("==" "!=")
    fi

    Selected_Operator=$(zenity --list --width=400 --height=600 \
    --title="Operators" --text="Choose an Operator to use in your condition:" \
    --column="Operators" "${operators[@]}")

    if [ $? -eq 1 ] || [ -z "$Selected_Operator" ]; then
        zenity --error --text="Operation Cancelled or No Operator Selected"
        return
    fi

    Condition_Value=$(zenity --entry --title="Enter Condition Value" --text="Enter Value to Compare with $ColumnCondition($DataTypeCondColumn):")

    if [ $? -eq 1 ] || [ -z "$Condition_Value" ]; then
        zenity --error --text="Operation Cancelled or No Value Entered"
        return
    fi

    Column_Number_filter=$(awk -F: -v selected_col="$ColumnCondition" 'NR>3 && $1 == selected_col {print NR-3}' "$tableName/$tableName.md")

    Filter_AND_Delete "$tableName" "$tableName/$tableName.md" "$Column_Number_filter" "$Selected_Operator" "$Condition_Value"
    
    source ../../TableScripts/Table_Menu.sh "$dbName"
}

Filter_And_Delete_Rows "$1" $2