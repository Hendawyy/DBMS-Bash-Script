#!/bin/bash
source ../../helper.sh
source ../../DataRetrievalHelper.sh
function selec_all_sql() {
    dbName=$1
    shift
    sql_command="$*"

    DBsPath="../../Databases/$dbName"
    tables=($(ls "$DBsPath"))
    
    read -ra sql_parts <<< "$sql_command"

    if [[ "${#sql_parts[@]}" -lt 4 || "${sql_parts[0]}" != "select" || ( "${sql_parts[1]}" != "*" && "${sql_parts[1]}" != "all" ) || "${sql_parts[2]}" != "from" ]]; then
        zenity --error --text="Invalid syntax! Must be: DELETE FROM table_name WHERE column operator value;"
        source ../../TableScripts/Table_Menu.sh "$dbName"
    fi  

    tableName="${sql_parts[3]}"
    
    if [ ! -d "$DBsPath/$tableName" ]; then
        zenity --error --text="Table '$tableName' does not exist in database '$dbName'."
        source ../../TableScripts/Table_Menu.sh "$dbName"
    fi

    tableDataPath="$DBsPath/$tableName/$tableName.data"
    metaDataPath="$DBsPath/$tableName/$tableName.md"

    formatted_data=$(retrieve_table_data_select_all "$dbName" "$tableName")

    zenity --text-info --title="$selectedTable Table" --width=1080 --height=950 \
        --html --filename=<(echo "$formatted_data") 2>>/dev/null

    # source ../../TableScripts/Table_Menu.sh "$dbName"
}

function select_all_columns_sql() {
    dbName=$1
    shift
    sql_command="$*"

    DBsPath="../../Databases/$dbName"

    tableName=$(echo "$sql_command" | awk '{print $(NF)}')

    selectedColumnsString=$(echo "$sql_command" | awk -F 'from' '{print $1}' | cut -d' ' -f2-)

    IFS=',' read -ra selectedColumns <<< "$selectedColumnsString"

    if [ ! -d "$DBsPath/$tableName" ]; then
        zenity --error --text="Table '$tableName' does not exist in database '$dbName'."
        source ../../TableScripts/Table_Menu.sh "$dbName"
    fi

    metaDataPath="$DBsPath/$tableName/$tableName.md"
    validColumns=($(awk -F: 'NR>3 {print $1}' "$metaDataPath"))
    validColumns=$(echo "$validColumns"  | awk '{print tolower($0)}' )
    selectedHeadersArr=()
    for column in "${selectedColumns[@]}"; do
        column=$(echo "$column" | xargs)
        if [[ ! " ${validColumns[@]} " =~ " $column " ]]; then
            zenity --error --text="Invalid column: '$column' does not exist in '$tableName'."
            source ../../TableScripts/Table_Menu.sh "$dbName"
        fi
        selectedHeadersArr+=("$column")
    done

    formatted_data=$(retrieve_selected_columns "$dbName" "$tableName" "${selectedHeadersArr[@]}")

    zenity --text-info --title="$tableName Table" --width=1080 --height=950 \
        --html --filename=<(echo "$formatted_data") 2>>/dev/null

    # source ../../TableScripts/Table_Menu.sh "$dbName"
}



