#!/bin/bash
source ../../helper.sh

function update_sql() {
    dbName=$1
    shift
    sql_command="$*"
    DBsPath="../../Databases/$dbName"

    read -ra sql_parts <<< "$sql_command"

    table_name=${sql_parts[1]}
    if [ ! -d "$DBsPath/$table_name" ]; then
        echo "Table '$table_name' does not exist in database '$dbName'."
        source ../../TableScripts/Table_Menu.sh "$dbName"
    fi

    tableDataPath="$DBsPath/$table_name/$table_name"
    metadataPath="$DBsPath/$table_name/$table_name.md"

    column_name=$(echo "$sql_command" | awk -F "[Ss][Ee][Tt]" '{print $2}' | awk -F "=" '{print $1}' | xargs)
    new_value=$(echo "$sql_command" | awk -F "[Ss][Ee][Tt]" '{print $2}' | awk -F "=" '{print $2}' | awk -F "[Ww][Hh][Ee][Rr][Ee]" '{print $1}' | xargs)
    condition=$(echo "$sql_command" | awk -F "[Ww][Hh][Ee][Rr][Ee]" '{print $2}' | xargs)
    
    filterColumnName=$(echo "$condition" | awk '{print $1}' | xargs)
    operator=$(echo "$condition" | awk '{print $2}' | xargs)
    condition_value=$(echo "$condition" | awk '{print $3}' | xargs)

    column_number=$(awk -F: -v colName="$column_name" 'NR > 3 && $1 == colName {print NR - 3; exit}' "$metadataPath")
    filterColumnNumber=$(awk -F: -v colName="$filterColumnName" 'NR > 3 && $1 == colName {print NR - 3; exit}' "$metadataPath")

    Filter_AND_Update "$tableDataPath" "$metadataPath" "$column_number" "$filterColumnNumber" "$operator" "$condition_value" "$new_value"
}

update_sql $1 $2
