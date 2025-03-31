#!/bin/bash
source ../../helper.sh

function insert_sql() {
    dbName=$1
    shift
    sql_command="$*"
    DBsPath="../../Databases/$dbName"

    sql_command=$(echo "$sql_command" | tr -s " " | xargs | sed 's/;$//')
    read -ra sql_parts <<< "$sql_command"

    if [[ "$(echo "${sql_parts[0]}" | awk '{print tolower($0)}')" != "insert" || \
          "$(echo "${sql_parts[1]}" | awk '{print tolower($0)}')" != "into" ]]; then
        zenity --error --width=400 --height=100 --title="Info" --text="Invalid syntax! Must start with 'INSERT INTO table_name VALUES (...)'."
        return 1
    fi

    table_name=${sql_parts[2]}
    if [ ! -d "$DBsPath/$table_name" ]; then
        echo "Table '$table_name' does not exist in database '$dbName'."
        return 1
    fi

    metadataPath="$DBsPath/$table_name/$table_name.md"

    sql_command=$(echo "$sql_command" | sed -E "s/\b${sql_parts[3]}\b/values/I")

    values_part="${sql_command#*values }"
    values=$(echo "$values_part" | tr -d '()' | xargs)

    number_of_columns=$(awk -F: 'NR==2 {print $2}' "$metadataPath")
    field_types=($(awk -F: 'NR>=4 {print $2}' "$metadataPath"))

    IFS=',' read -ra value_array <<< "$values"

    if [[ "${#value_array[@]}" -ne "$number_of_columns" ]]; then
        echo "Column count mismatch! Expected $number_of_columns, but got ${#value_array[@]} values."
        return 1
    fi

    echo "DEBUG: Expected columns: $number_of_columns"
    echo "DEBUG: Inserted values: ${value_array[@]}"
    echo "DEBUG: Field types: ${field_types[@]}"

    flag=0 

    for ((i = 0; i < number_of_columns; i++)); do
    field_type="${field_types[i]}"
    value="${value_array[i]// /}"
    echo "DEBUG: Checking column $i with value '$value' against type '$field_type'"

    if [[ "$field_type" == "ID--Int--Auto--Inc." ]]; then
        last_id=$(tail -n1 "$DBsPath/$table_name/$table_name" | cut -d':' -f1)
        new_id=$(( ${last_id:-0} + 1 ))
        value_array[i]="$new_id"
        echo "Ignoring Set ID Auto-Increment ID is set to: $new_id"

    elif [[ "$field_type" == "Enum" ]]; then
        zxc=$DBsPath/$table_name/$table_name
        if ! validate_enum "$value" "$((i+1))" "$zxc" "SQL"; then
            echo "Invalid ENUM for column $i"
            flag=1
        fi

    elif [[ "$field_type" == "password" ]]; then
        hashedPassword=$(echo -n "$value" | sha256sum | awk '{print $1}')
        value_array[i]=$hashedPassword

    elif [[ "$field_type" == "current_timestamp" || "$value" == "current_timestamp" ]]; then
        value_array[i]=$(date +"%Y-%m-%d-%H/%M/%S") 

    else
        validate_result=$(validate_input "$value" "$field_type")
        if [[ "$validate_result" -ne 0 ]]; then
            echo "DEBUG: Validation failed for column $i ($field_type)"
            flag=1
        fi
    fi
done


    if [[ "$flag" -eq 0 ]]; then
        formatted_values=$(IFS=:; echo "${value_array[*]}")
        formatted_values="${formatted_values// /}"
        # INSERT INTO new_table_1 VALUES (24, "Aya", 30, "F", 22.3, "aya@example.com", "mypassword", "01122334455", "95/05/15");
	    # INSERT INTO meezo VALUES (24, "Messi", "F");
        echo "$formatted_values" >> "$zxc"
        echo "Record inserted successfully: $formatted_values"
    else
        echo "Record insertion failed due to validation errors."
    fi
}

insert_sql "$1" "$2"
