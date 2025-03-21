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
    source $Table_Menu_Script $db
}

# The GUISQL function is used to prompt the user to choose between GUI and SQL mode for table operations.
function GUISQL(){
    script_name=$1
    db_name=$2
    type=$(zenity --list --width=420 --height=380 \
    --title="Do you want To Use GUI or SQL" --text="Choose an Option From The Given" --column="Options" \
    "GUI" "SQL")
    if [ $? -eq 1 ]; then
        Table_Menu $db_name
    fi

    if [[ "$type" == "GUI" ]]; then
        source $GUI_Scripts_path/$script_name $db_name
    elif [[ "$type" == "SQL" ]]; then
        SQL_Mode "$script_name" "$db_name"
    else
        zenity --error --text="Invalid Option"
        GUISQL "$script_name" "$db_name"
    fi
}

# The SQL_Mode function is used to call the SQL scripts for table operations.
function SQL_Mode(){
    script_name=$1
    db_name=$2

    case "$script_name" in
        "create_Table.sh")
            source $SQL_Scripts_Path/SQLCreateTable.sh "$db_name"
            ;;
        "drop_Table.sh")
            source $SQL_Scripts_Path/SQLDropTable "$db_name"
            ;;
        "insert_into_Table.sh")
            source $SQL_Scripts_Path/SQLInsertIntoTable.sh "$db_name"
            ;;
        "select_from_Table.sh")
            source $SQL_Scripts_Path/SQLSelectFromTable.sh "$db_name"
            ;;
        "delete_from_Table.sh")
            source $SQL_Scripts_Path/SQLDeleteFromTable.sh "$db_name"
            ;;
        "update_Table.sh")
            source $SQL_Scripts_Path/SQLUpdateTable.sh "$db_name"
            ;;
        *)
            zenity --error --text="Invalid Option"
            Table_Menu $db_name
            ;;
    esac
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
    enum_values=$(awk -F: -v i="$((column_number+3))" 'NR == i {print $NF}' "$table_name/$table_name.md")
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

    echo "field_types: ${field_types[@]}"

    IFS="," read -r -a user_input_array <<< "$user_input"

    number_of_columns=${#field_types[@]}
    
    password_index=-1  

    for ((i = 0; i < number_of_columns; i++)); do
        echo "Validating: ${user_input_array[$i]}"

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
            print "Checking row:", $0
            print "Column value:", $col
            if ($col == value) {
                print "Duplicate found: " $col
                found = 1  
                exit 1 
            }
        }
        END {
            if (found == 0) {
                print "No duplicates found."
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



