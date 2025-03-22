#!/bin/bash

function filter_matching() {
    tableDataPath="$1"
    columnNumberZ="$2"
    operator="$3"
    value="$4"
    tempFile="$5"
    functionName="$6"
    
    awk -F ":" -v col="$columnNumberZ" -v val="$value" -v op="$operator" -v func="$functionName" '
        BEGIN { IGNORECASE=1; }
        {
            columnValue = $col
            compareValue = val
            isNumeric = (columnValue + 0 == columnValue) && (compareValue + 0 == compareValue)

            if (isNumeric) {
                columnValue += 0
                compareValue += 0
            }

            matchFound = 0

            if (op == "==" && columnValue == compareValue) matchFound = 1
            if (op == "!=" && columnValue != compareValue) matchFound = 1
            if (op == ">=" && columnValue >= compareValue) matchFound = 1
            if (op == "<=" && columnValue <= compareValue) matchFound = 1
            if (op == ">"  && columnValue > compareValue)  matchFound = 1
            if (op == "<"  && columnValue < compareValue)  matchFound = 1

            if (func == "Delete") {
                if (!matchFound) { print $0 }
            } else {
                if (matchFound) { print $0 }
            }

        }' "$tableDataPath" > "$tempFile"
}

function Filter_And_Delete_Rows() {
    tableName=$1
    dbName=$(basename "$(pwd)")

    Column_Names=$(awk -F: 'NR>3 {print $1}' "$tableName/$tableName.md")

    ColumnCondition=$(zenity --list --width=400 --height=600 \
    --title="Columns in $tableName" --text="Choose a Column To Filter On:" \
    --column="Columns" $Column_Names)

    if [ $? -eq 1 ] || [ -z "$ColumnCondition" ]; then
        zenity --error --text="Operation Cancelled or No Column Selected"
        table_Menu $dbName
        return
    fi

    DataTypeCondColumn=$(awk -F: -v colName="$ColumnCondition" 'NR>3 {if($1==colName) print $2}' "$tableName/$tableName.md")

    if [[ "$DataTypeCondColumn" == "ID--Int--Auto--Inc." || "$DataTypeCondColumn" == "INT" || "$DataTypeCondColumn" == "Double" || "$DataTypeCondColumn" == "Date" || "$DataTypeCondColumn" == "Current--Date--Time" ]]; then
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
}

function Filter_AND_Delete() {
    tableName=$1
    metaDataPath=$2
    columnNumber=$3
    operator=$4
    value=$5
    dbName=$(basename "$(pwd)")

    functionName="Delete"

    tempFile=$(mktemp)
    filter_matching "$tableName/$tableName" "$columnNumber" "$operator" "$value" "$tempFile" "$functionName"
    if [ $(wc -l < "$tempFile") -eq $(wc -l < "$tableName/$tableName") ]; then
        zenity --error --text="No Rows Found Matching the Condition"
    else
        mv "$tempFile" "$tableDataPath"
        zenity --info --text="Rows Matching the Condition have been Deleted Successfully"
    fi

    Table_Menu $dbName
}

Filter_And_Delete_Rows "$1"
