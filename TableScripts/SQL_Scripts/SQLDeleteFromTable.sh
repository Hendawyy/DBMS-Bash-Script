#!/bin/bash
source ../../helper.sh

function delete_sql() {
    dbName=$1
    shift
    sql_command="$*"

    DBsPath="../../Databases/$dbName"
    tables=($(ls "$DBsPath"))

    sql_command=$(echo "$sql_command" | awk '{print tolower($0)}' | tr -s " " | xargs)
    read -ra sql_parts <<< "$sql_command"

    tableName="${sql_parts[2]}"
    ColumnCondition="${sql_parts[4]}"
    Selected_Operator="${sql_parts[5]}"
    Condition_Value="${sql_parts[6]}"
    Condition_Value="${Condition_Value//;/}"

    if [ ! -d "$DBsPath/$tableName" ]; then
        # clear
        echo "Table '$tableName' does not exist in database '$dbName'."
        source ../../TableScripts/Table_Menu.sh "$dbName"
    fi
    

    tableDataPath="$DBsPath/$tableName/$tableName"
    metaDataPath="$DBsPath/$tableName/$tableName.md"

    Column_Number_filter=$(awk -F: -v selected_col="$ColumnCondition" 'NR>3 && $1 == selected_col {print NR-3}' "$metaDataPath")

    if [ -z "$Column_Number_filter" ]; then
        # clear
        echo "Column '$ColumnCondition' does not exist in table '$tableName'."
        source ../../TableScripts/Table_Menu.sh "$dbName"
    fi

    Filter_AND_Delete "$tableName" "$metaDataPath" "$Column_Number_filter" "$Selected_Operator" "$Condition_Value"
    # source ../../TableScripts/Table_Menu.sh "$dbName"
}

delete_sql $1 $2

