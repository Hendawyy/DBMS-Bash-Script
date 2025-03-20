#!/bin/bash
source ../../helper.sh
echo "from insert_into_Table $(pwd)"


# takes input from user 
function insert_into_Table {
    
    db_name=$(basename "$(pwd)")

    table_name=$1

    if [ ! -e "$table_name" ]; then
        zenity --error --text="Error: Table does not exist!"
        Table_Menu $db_name
    fi

    if [ ! -e "$table_name/$table_name.md" ]; then
        zenity --error --text="Error: Metadata file is empty!"
        Table_Menu $db_name
    fi

    number_of_columns=$( awk -F: ' NR==2 {print $2}'  "$table_name/$table_name.md" )

    form_entries=()
    auto_increment_index=0
    current_timestamp_index=0
    field_names=($(awk -F: 'NR>=4 {print $1}' "$table_name/$table_name.md"))

    field_types=()
    for ((i = 0; i < number_of_columns; i++)); do
        field_type=$(awk -F: -v i="$((i + 4))" '{if (NR == i) print $2}' "$table_name/$table_name.md")
        field_types+=("$field_type")
    done

    for ((i = 0; i < number_of_columns; i++)); do
        field_type="${field_types[i]}"
        field="${field_names[i]}"
        
        if [[ "$field_type" == "date" ]]; then
            form_entries+=(--add-calendar="$field")
        elif [[ "$field_type" == "Enum" ]]; then
            enum_values=$(awk -F: -v i="$((i+4))" '{if (NR == i) print $NF}' "$table_name/$table_name.md" | tr -d '{}')
            IFS=" " read -r -a enum_values_array <<<"$enum_values"
            form_entries+=(--add-combo="$field" --combo-values="$(printf "%s|" "${enum_values_array[@]}" | sed 's/|$//')")
        elif [[ "$field_type" == "password" ]]; then
            password_index=$((i + 1))
            form_entries+=(--add-password="$field")
        elif [[ "$field_type" == "ID--Int--Auto--Inc." ]]; then
            auto_increment_index=$((i + 1))
        elif [[ "$field_type" == "date" ]]; then
            form_entries+=(--add-calendar="$field")
        elif [[ "$field_type" == "current_timestamp" ]]; then
            current_timestamp_index=$((i + 1))
        else
            form_entries+=(--add-entry="$field")
        fi
    done

    while true; do
        flag=0  
        user_input=$(zenity --forms --title="Insert Into $table_name" --text="Enter the following details" --separator="," "${form_entries[@]}")
        echo "User input: $user_input"
        if [ $? -ne 0 ]; then
            break  
        fi

        if [ "$auto_increment_index" -ne 0 ]; then
            auto_increment_index=$((auto_increment_index + 0))
            last_value=$(tail -1 "$table_name/$table_name" | awk -F: -v colIndex="$auto_increment_index" '{print $colIndex}')

            if [[ -z "$last_value" ]]; then
                auto_increment_value=1
            else
                auto_increment_value=$((last_value + 1))
            fi
            user_input="$auto_increment_value,$user_input"
        fi


        # =======================================================================================================
        # =======================================================================================================
        # =======================================================================================================
        # =======================================================================================================
        # =======================================================================================================
        # =======================================================================================================
        # =======================================================================================================
        if [ "$current_timestamp_index" -gt 0 ]; then
            current_timestamp=$(date +"%Y-%m-%d %H/%M/%S")  # Standard timestamp format

            IFS="," read -r -a user_input_array <<<"$user_input"

            # Ensure index is within the valid range
            if [ "$current_timestamp_index" -le "$(( ${#user_input_array[@]} + 1 ))" ]; then
                # Insert timestamp at the correct position
                user_input_array=("${user_input_array[@]:0:$((current_timestamp_index - 1))}" \
                                "$current_timestamp" \
                                "${user_input_array[@]:$((current_timestamp_index - 1))}")

                # Convert array back to CSV string
                user_input=$(IFS=,; echo "${user_input_array[*]}")
            else
                echo "Error: current_timestamp_index ($current_timestamp_index) is out of bounds."
                return 1
            fi
        fi
        # =======================================================================================================
        # =======================================================================================================
        # =======================================================================================================
        # =======================================================================================================
        # =======================================================================================================
        # =======================================================================================================

        if [ $? -ne 0 ]; then
            break  
        fi

        if [ -z "$user_input" ]; then
            zenity --error --text="No data entered. Please enter the data."
            continue
        fi

        IFS="," read -r -a user_input_array <<< "$user_input"  

        if validate_input "$user_input" "${field_types[@]}"; then
            for ((i = 0; i < number_of_columns; i++)); do

                primary_key_check=$(awk -F: 'NR == '"$((i+4))"' {print $3}' "$table_name/$table_name.md")
                unique_key_check=$(awk -F: 'NR == '"$((i+4))"' {print $4}' "$table_name/$table_name.md")
                not_null_check=$(awk -F: 'NR == '"$((i+4))"' {print $5}' "$table_name/$table_name.md")

                if [[ "$primary_key_check" == "y" ]]; then
                    if ! check_primary_key "$table_name" "${user_input_array[i]}" "$((i+1))"; then
                        zenity --error --text="Primary key constraint violated for ${field_names[i]}."
                        flag=1
                        break  
                    fi  
                fi

                if [[ "$unique_key_check" == "y" ]]; then
                    if ! check_unique_key "$table_name" "${user_input_array[i]}" "$((i+1))"; then
                        zenity --error --text="Unique key constraint violated for ${field_names[i]}."
                        flag=1
                        break  
                    fi  
                fi

                if [[ "$not_null_check" == "y" ]]; then
                    if ! check_not_null "${user_input_array[i]}" ; then
                        zenity --error --text="Not null constraint violated for ${field_names[i]}."
                        flag=1
                        break  
                    fi  
                fi
            done

            echo "flag: $flag"

            if [ "$flag" -eq 0 ]; then
                echo "Inserting record..."
                insert_record "$table_name" "$user_input"
                break
            fi
        fi
    done
    Table_Menu $db_name
}

insert_into_Table $1
