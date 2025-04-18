#!/bin/bash
# exec 2>/dev/null
# Description: This file contains the helper functions for the database management system.
# Path to the Databases directory
dbPath="Databases"
# scripts to be sourced
Table_Menu_Script="../../TableScripts/Table_Menu.sh"
Database_Scripts_Path="../../DatabaseScripts"
SQL_Scripts_Path="../../TableScripts/SQL_Scripts"
GUI_Scripts_path="../../TableScripts/GUI_Scripts" 

# The validate_name function is used to validate the database name entered by the user.
function validate_name {
    name=$1
    if [[ ! "$name" =~ ^[a-zA-Z][a-zA-Z0-9_]*$ ]]; then
        return 1
    fi
    return 0
}

# The check_DB_exists function is used to check if the database already exists.
function check_DB_exists {
    dbName=$1
    if [ -d "$dbPath/$dbName" ]; then
        return 1
    fi    
    return 0
}
# The check_TB_exists function is used to check if the table already exists.
function check_TB_exists {
    dbName=$1
    tbName=$2
    if [ -d "$dbPath/$dbName/$tbName" ]; then
        return 1
    fi
    return 0
}

# The list_DBs function is used to list all the databases in the Databases directory. The user is prompted to select a database to connect to.
function list_DBs() {
    databses=$(ls Databases/)
    selected_db=$(zenity --list --width=400 --height=600 \
    --title="List of Databases" --text="Choose a Database To Connect to:" --column="Databases" $databses)
    if [ $? -eq 1 ]; then
        DBMenu
    fi
    if [ -z $selected_db ]; then
        zenity --error --text="No Database Selected"
        list_DBs
    fi
    zenity --question --text="Do You Want To Connect To $selected_db?"
    if [ $? -eq 0 ]; then
        connect_DB $selected_db
    else
        zenity --info --text="You Have Decided Not To Connect To $selected_db"
        DBMenu
    fi
    return 0
}

# The connect_DB function is used to connect to a database. It takes the database name as input and changes the current directory to the selected database directory.
function connect_DB() {
    db=$1
    cd Databases/$db/
    zenity --info --text="Connected To $db"
    GUISQL $db
    # source $Table_Menu_Script $db
}

# The GUISQL function is used to prompt the user to choose between GUI and SQL mode for table operations.
function GUI(){
    script_name=$1
    tableName=$2
    db_name=$3
    source $GUI_Scripts_path/$script_name $db_name $tableName
}

# The GUISQL function is used to prompt the user to choose between GUI and SQL mode for table operations.
function GUISQL(){
    db_name=$1
    type=$(zenity --list --width=420 --height=380 \
    --title="Do you want To Use GUI or SQL" --text="Choose an Option From The Given" --column="Options" \
    "GUI" "SQL")
    if [ $? -eq 1 ]; then
        cd ../..
        list_DBs
    fi
    if [[ "$type" == "GUI" ]]; then
        source ../../TableScripts/Table_Menu.sh "$db_name"
    elif [[ "$type" == "SQL" ]]; then
        # script_name=$(basename $script_name)
        SQL_accept_command $db_name
    else
        zenity --error --text="Invalid Option"
        GUISQL "$script_name" "$tableName" "$db_name"
    fi
}

# The SQL_accept_command function is used to prompt the user to enter an SQL command.
function SQL_accept_command() {
    dbName=$1
    DBsPath="../../Databases/$dbName"

    type=$(zenity --list --width=520 --height=380 \
    --title="Do you want to use GUI or Terminal for SQL Command?" \
    --column="Options" "GUI" "Terminal")

    if [ $? -eq 1 ]; then
        source ../../TableScripts/Table_Menu.sh "$dbName"
    fi

    if [[ "$type" == "GUI" ]]; then
        sql_command=$(zenity --entry --width=750 --title="SQL Command" --text="Enter the SQL Command:")
        if [ $? -eq 1 ]; then
            zenity --info --width=400 --height=100 --title="Info" --text="Operation Cancelled"
            source ../../TableScripts/Table_Menu.sh "$dbName"
        fi
    elif [[ "$type" == "Terminal" ]]; then
        while true; do
            read -e -p "Enter the SQL Command: " sql_command
            if [ -z "$sql_command" ]; then
                zenity --error --text="No Command Entered"
                SQL_accept_command "$dbName"
            fi

            sql_command=$(echo "$sql_command" | tr -s " " | xargs | sed 's/;$//')

            sql_type=$(echo "$sql_command" | awk '{print tolower($1)}')

            if [[ "$sql_type" == "exit" ]]; then
                zenity --info --width=400 --height=100 --title="Info" --text="Exiting SQL Command Mode"
                source ../../TableScripts/Table_Menu.sh "$dbName"
            fi

            read -ra sql_parts <<< "$sql_command"

            if [[ "$(echo "${sql_parts[0]}" | awk '{print tolower($0)}')" != "insert" && \
                    "$(echo "${sql_parts[0]}" | awk '{print tolower($0)}')" != "drop" && \
                        "$(echo "${sql_parts[0]}" | awk '{print tolower($0)}')" != "select" && \
                            "$(echo "${sql_parts[0]}" | awk '{print tolower($0)}')" != "update" && \
                                "$(echo "${sql_parts[0]}" | awk '{print tolower($0)}')" != "delete" ]]; then
                echo "Invalid syntax! Please enter a valid SQL command."
                continue
            fi  

            case "$sql_type" in
                "insert")
                    source $SQL_Scripts_Path/SQLInsertIntoTable.sh "$db_name" "$sql_command"
                    ;;
                "select")
                    source $SQL_Scripts_Path/SQLSelectFromTable.sh 
                    sql_command=$(echo "$sql_command" | sed 's/;$//')
                    sql_command=$(echo "$sql_command" | awk '{print tolower($0)}' | tr -s " " | xargs) 
                    select_part=$(echo "$sql_command" | awk -F 'from' '{print $1}' | awk '{print $2}')

                    if [[ "$select_part" == "*" || "$select_part" == "all" ]]; then
                        selec_all_sql "$dbName" "$sql_command"
                    else
                        select_all_columns_sql "$dbName" "$sql_command"
                    fi
                    ;;
                "update")
                    if ! [[ "$sql_command" =~ ^[Uu][Pp][Dd][Aa][Tt][Ee]\ [a-zA-Z_][a-zA-Z0-9_]*\ [Ss][Ee][Tt]\ [a-zA-Z_][a-zA-Z0-9_]*\ *=\ *.+\ [Ww][Hh][Ee][Rr][Ee]\ [a-zA-Z_][a-zA-Z0-9_]*\ *=\ *.+$ ]]; then
                        echo "Invalid syntax! Please enter a valid SQL command."
                        echo "Valid syntax: UPDATE table_name SET column = value WHERE column = value;"
                        continue
                    else
                        source $SQL_Scripts_Path/SQLUpdateTable.sh "$db_name" "$sql_command"
                    fi
                    ;;
                "delete")
                    if ! [[ "$sql_command" =~ ^[Dd][Ee][Ll][Ee][Tt][Ee]\ [Ff][Rr][Oo][Mm]\ [a-zA-Z_][a-zA-Z0-9_]*\ [Ww][Hh][Ee][Rr][Ee]\ [a-zA-Z_][a-zA-Z0-9_]*\ *=\ *.+$ ]]; then
                        echo "Invalid syntax! Please enter a valid SQL command."
                        echo "Valid syntax: DELETE FROM table_name WHERE column = value;"
                        continue
                    else
                        source $SQL_Scripts_Path/SQLDeleteFromTable.sh "$db_name" "$sql_command"
                    fi
                    ;;
                "drop")
                    if ! [[ "$sql_command" =~ ^[Dd][Rr][Oo][Pp]\ [Tt][Aa][Bb][Ll][Ee]\ [a-zA-Z_][a-zA-Z0-9_]*$ ]]; then
                        echo    "Invalid syntax! Please enter a valid SQL command."
                        echo    "Valid syntax: DROP TABLE table_name;"
                        continue
                    else
                        source $SQL_Scripts_Path/SQLDropTable.sh "$db_name" "$sql_command"
                    fi 
                    ;;
                *)
                    echo "Invalid SQL command: '$sql_command'"
                    continue
                    ;;
            esac
        done
    else
        zenity --error --text="Invalid Option"
        source ../../TableScripts/Table_Menu.sh "$dbName"
    fi
}


# The validate_int function is used to validate an integer input.
function validate_int(){
    int=$1
    if [[ ! "$int" =~ ^[0-9]+$ ]]; then
        return 1
    fi
    return 0
}

# The validate_double function is used to validate a double input.
function validate_double(){
    double=$1
    if [[ ! "$double" =~ ^[0-9]+(\.[0-9]+)?$ ]]; then
        return 1
    fi
    return 0
}

# The validate_varchar function is used to validate a varchar input.
function validate_varchar(){
    varchar=$1
    if ! validate_name "$varchar"; then 
        return 1
    fi
    return 0
}

# The validate_phone function is used to validate a phone number input.
function validate_phone(){
    phone=$1
    if [[ ! "$phone" =~ ^01[0-9]{9}$ ]]; then
        return 1
    fi
    return 0
}

# The validate_email function is used to validate an email input.
function validate_email(){
    email=$1
    if [[ ! "$email" =~ ^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,4}$ ]]; then
        return 1
    fi
    return 0
}

# The validate_password function is used to validate a password input.
function validate_password(){
    password=$1
    if [[ ! "$password" =~ ^[a-zA-Z0-9]{8,}$ ]]; then
        return 1
    fi
    return 0
}

# The validate_date function is used to validate a date input.
function validate_date(){
    date=$1
    if [[ ! "$date" =~ ^[0-9]{4}-(0[1-9]|1[0-2])-(0[1-9]|[1-2][0-9]|3[0-1])$ ]]; then
        return 1
    fi
    return 0
}

# The validate_enum function is used to validate an enum input.
validate_enum() {
    enum_value=$1 
    column_number=$2
    table_name=$3
    type=$4
    if [ "$type" == "SQL" ]; then
        enum_values=$(awk -F: -v i="$((column_number+3))" 'NR == i {print $NF}' "$table_name.md")
    else
        enum_values=$(awk -F: -v i="$((column_number+3))" 'NR == i {print $NF}' "$table_name/$table_name.md")
    fi

    clean_enum_values=$(echo "$enum_values" | tr -d '{}')
    IFS=" " read -r -a enum_values_array <<<"$clean_enum_values"

    for value in "${enum_values_array[@]}"; do
        if [[ "$value" == "$enum_value" ]]; then
            return 0
        fi
    done
    return 1
}


# The validate_input function is used to validate the user input based on the field types.
function validate_input {
    user_input=$1
    shift 1
    field_types=("$@")

    IFS="," read -r -a user_input_array <<< "$user_input"

    number_of_columns=${#field_types[@]}
    password_index=-1  

    for ((i = 0; i < number_of_columns; i++)); do

        case "${field_types[$i]}" in  
            "int")
                if ! validate_int "${user_input_array[$i]}"; then
                    zenity --error --text="Invalid input: ${user_input_array[$i]}, Please enter an integer."
                    return 1
                fi
                ;;
            "double")
                if ! validate_double "${user_input_array[$i]}"; then
                    zenity --error --text="Invalid input: ${user_input_array[$i]}, Please enter a double."
                    return 1
                fi
                ;;
            "varchar")
                if ! validate_varchar "${user_input_array[$i]}"; then
                    zenity --error --text="Invalid input: ${user_input_array[$i]}, Please enter a varchar."
                    return 1
                fi
                ;;
            "phone")
                if ! validate_phone "${user_input_array[$i]}"; then
                    zenity --error --text="Invalid input: ${user_input_array[$i]}, Please enter a valid phone number."
                    return 1
                fi
                ;;
            "email")
                if ! validate_email "${user_input_array[$i]}"; then
                    zenity --error --text="Invalid input: ${user_input_array[$i]}, Please enter a valid Email."
                    return 1
                fi
                ;;
            "password")
                password_index=$i
                ;;
            "current_timestamp")
                current_timestamp_index=$i
                ;;
        esac
    done

    if [ "$password_index" -ne -1 ]; then
        password="${user_input_array[$password_index]}"
        hashed_password=$(echo -n "$password" | sha256sum | awk '{print $1}')
        user_input_array[$password_index]=$hashed_password
        user_input=$(IFS=,; echo "${user_input_array[*]}")
    fi
    return 0
}


# The insert_record function is used to insert a record into a table.
insert_record() {
    table_name=$1
    user_input=$2
    
    IFS="," read -r -a user_input_array <<<"$user_input"
    record=$(IFS=":"; echo "${user_input_array[*]}")

    echo "$record" >> "$table_name/$table_name"
    if [ $? -eq 0 ]; then
        zenity --info --text="Record inserted successfully."
    else
        zenity --error --text="Failed to insert record."
    fi
    Table_Menu $3
}

# The check_primary_key function is used to check if a value is a primary key.
check_primary_key() {
    table_name=$1
    primary_key_value=$2
    column_number=$3  

    if ! check_unique_key "$table_name" "$primary_key_value" "$column_number"; then
        return 1 
    fi

    if [[ -z "$primary_key_value" ]]; then
        return 1 
    fi

    return 0  
}

# The check_unique_key function is used to check if a value is unique.
check_unique_key() {
    table_name=$1
    unique_key_value=$2
    column_number=$3
    awk -F: -v col="$column_number" -v value="$unique_key_value" '
        BEGIN { found = 0 } 
        {
            if ($col == value) {
                print "Duplicate found: " $col
                found = 1  
                exit 1 
            }
        }
        END {
            if (found == 0) {
                exit 0  
            }
        }
    ' "$table_name/$table_name"

    return $? 
}

# The check_not_null function is used to check if a value is not null.
check_not_null() {
    not_null_value="$1"

    if [[ -z "$not_null_value" ]]; then
        return 1  
    fi
    return 0  
}

# The filter_matching function is used to filter rows based on a condition.
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

            if ((op == "==" || op == "=") && columnValue == compareValue) matchFound = 1
            if (op == "!=" && columnValue != compareValue) matchFound = 1
            if (op == ">=" && columnValue >= compareValue) matchFound = 1
            if (op == "<=" && columnValue <= compareValue) matchFound = 1
            if (op == ">"  && columnValue > compareValue)  matchFound = 1
            if (op == "<"  && columnValue < compareValue)  matchFound = 1

            if (func == "DELETE") {
                if (!matchFound) { print $0 }
            } else {
                if (matchFound) { print $0 }
            }

        }' "$tableDataPath" > "$tempFile"

}

function Filter_AND_Delete() {
    tableName=$1
    metaDataPath=$2
    columnNumber=$3
    operator=$4
    value=$5
    dbName=$(basename "$(pwd)")
    functionName="DELETE"

    tempFile=$(mktemp)
    filter_matching "$tableName/$tableName" "$columnNumber" "$operator" "$value" "$tempFile" "$functionName"
    if [ $(wc -l < "$tempFile") -eq $(wc -l < "$tableName/$tableName") ]; then
        zenity --error --text="No Rows Found Matching the Condition"
    else
        mv "$tempFile" "$tableDataPath"
        zenity --info --text="Rows Matching the Condition have been Deleted Successfully"
    fi

    
}

function Filter_AND_Update() {
    tableDataPath="$1"
    metaDataPath="$2"
    columnNumber="$3"
    filterColumnNumber="$4"
    operator="$5"
    conditionValue="$6"
    newValue="$7"
    functionName="UPDATE"


    tempFile="matchingRows.tmp"

    filter_matching "$tableDataPath" "$filterColumnNumber" "$operator" "$conditionValue" "$tempFile" "$functionName"
    numberOfAffectedRows=$(wc -l < "$tempFile")
    
    if [ "$numberOfAffectedRows" -eq 0 ]; then
        zenity --info --width=400 --height=100 --title="Info" --text="No Rows Matched the Condition"
        rm $tempFile
        source ../../TableScripts/Table_Menu.sh "$dbName"
    fi

    uniqueness_Check=$(awk -F: -v colNum="$columnNumber" '
        NR > 3 {
            if (NR-3 == colNum && ($3 == "y" || $4 == "y")) 
                print "unique"
        }
    ' "$metaDataPath")

    if [ "$uniqueness_Check" == "unique" ]; then
        if [ "$numberOfAffectedRows" -gt 1 ]; then
            zenity --error --text="Multiple Rows Matched the Condition, Can't Update Unique Column"
            rm "$tempFile"
            Table_Menu $1
        fi
    fi

    awk -F: -v colNum="$columnNumber" -v newValue="$newValue" '
        NR==FNR { matchedIDs[$1] = 1; next }
        {
            if ($1 in matchedIDs) {
                for (i = 1; i <= NF; i++) {
                    if (i == colNum) {
                        printf newValue
                    } else {
                        printf $i
                    }
                    if (i < NF) printf ":"
                }
                print ""
            } else {
                print $0
            }
        }
    ' "$tempFile" "$tableDataPath" > temp.tmp


    mv temp.tmp "$tableDataPath"
    rm "$tempFile"

    zenity --info --width=400 --height=100 --title="Info" --text="Table Updated Successfully"
}
