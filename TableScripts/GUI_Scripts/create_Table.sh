#!/bin/bash
source ../../helper.sh

# The create_Table function is used to create a table in the selected database.
function create_Table {
    tableName=$(zenity --entry --width=400 --height=100 --title="Create Table" --text="Enter Table Name")
    if [ $? -ne 0 ]; then
        zenity --error --width=400 --height=100 --title="Error" --text="Table Creation Cancelled"
        Table_Menu $1
    fi
    if [ -z "$tableName" ]; then
        zenity --error --width=400 --height=100 --title="Error" --text="Table Name cannot be empty"
        create_Table $1
    fi
    
    tableName=$(echo "$tableName" | xargs | awk '{print tolower($0)}' | sed 's/ /_/g')
    
    validate_name "$tableName"
    if [ $? -ne 0 ]; then
        zenity --error --width=400 --height=100 --title="Error" --text="Invalid Table Name"
        create_Table $1
    fi
    check_TB_exists "$1" "$tableName"
    if [ $? -ne 0 ]; then
        zenity --error --width=400 --height=100 --title="Error" --text="Table Already Exists"
        create_Table $1
    fi
    numColumns=$(zenity --entry --width=400 --height=100 --title="Create Table" --text="Enter Number of Columns")
    if [ $? -ne 0 ]; then
        zenity --error --width=400 --height=100 --title="Error" --text="Table Creation Cancelled"
        Table_Menu $1
    fi
    if [ -z "$numColumns" ]; then
        zenity --error --width=400 --height=100 --title="Error" --text="Number of Columns cannot be empty"
        create_Table $1
    fi
    if ! [[ "$numColumns" =~ ^[0-9]+$ ]]; then
        zenity --error --width=400 --height=100 --title="Error" --text="Invalid Number of Columns"
        create_Table $1
    fi
    
    mkdir -p "$tableName"
    touch "$tableName/$tableName" "$tableName/$tableName.md"
    echo "TableName:$tableName" > "$tableName/$tableName.md"
    echo "Number_of_Columns:$numColumns" >> "$tableName/$tableName.md"
    echo "Column_Name:Type:Primary_Key(y/n):Unique:Not_Null" >> "$tableName/$tableName.md"
    
    columns=()
    data_types=()
    primary_keys=()
    nullable=()
    unique=()
    for(( i=1; i <= numColumns; i++ )); do
        column=$(zenity --forms --width=400 --height=100 --title="Create Table $tableName" --text="Enter Info For Column($i)"\
        --add-entry="Column Name"\
        --add-entry="Unique(y/n)"\
        --add-entry="Not Null(y/n)")
        if [ $? -
    value+=($UpdateValue)ne 0 ]; then
            zenity --error --width=400 --height=100 --title="Error" --text="$tableName Creation Cancelled"
            Table_Menu $1
        fi
        if [ -z "$column" ]; then
            zenity --error --width=400 --height=100 --title="Error" --text="$tableName Creation Failed"
            rm -r "$tableName"
            create_Table $1
        fi
        name=$(echo $column | cut -d "|" -f 1)
        unique=$(echo $column | cut -d "|" -f 2)
        nullable=$(echo $column | cut -d "|" -f 3)
        name=$(echo "$name" | xargs | awk '{print tolower($0)}' | sed 's/ /_/g')
        unique=$(echo "$unique" | xargs | awk '{print tolower($0)}')
        nullable=$(echo "$nullable" | xargs | awk '{print tolower($0)}')
        validate_name "$name"
        if [ $? -ne 0 ]; then
            zenity --error --width=400 --height=100 --title="Error" --text="Invalid Table Name"
            rm -r "$tableName"
            create_Table $1
        fi
        columns+=($name)
        if [[ "$unique" != "y" && "$unique" != "n" ]]; then
            zenity --error --width=400 --height=100 --title="Error" --text="Invalid Unique Value"
            rm -r "$tableName"
            create_Table $1
        fi

        if [[ "$nullable" != "y" && "$nullable" != "n" ]]; then
            zenity --error --width=400 --height=100 --title="Error" --text="Invalid Not Null Value"
            rm -r "$tableName"
            create_Table $1
        fi
        unique+=($unique)
        nullable+=($nullable)
        data_type=$(zenity --list --width=400 --height=450 --title="Create Table $tableName" --text="Select Data Type For Column($i)"\
        --column="Data Types"\
        "ID--Int--Auto--Inc." "int" "double" "varchar" "Enum" "Phone" "Email" "Password" "Date" "Current--Date--Time")
        if [ $? -ne 0 ]; then
            zenity --error --width=400 --height=100 --title="Error" --text="$tableName Creation Cancelled"
            rm -r "$tableName"
            create_Table $1
        fi
        if [ -z "$data_type" ]; then
            zenity --error --width=400 --height=100 --title="Error" --text="$tableName Creation Failed"
            rm -r "$tableName"
            create_Table $1
        fi
        if [[ "$data_type" == "Enum" ]]; then
            enum_count=$(zenity --entry --width=400 --height=100 --title="Create Table $tableName" --text="Enter The Desired Number of Enum Values For $name")

            if [ $? -ne 0 ]; then
                zenity --error --width=400 --height=100 --title="Error" --text="$tableName Creation Cancelled"
                rm -r "$tableName"
                create_Table $1
            fi

            enum_count=$(echo "$enum_count" | xargs)
            if [[ -z "$enum_count" || ! "$enum_count" =~ ^[0-9]+$ || "$enum_count" -le 0 ]]; then
                zenity --error --width=400 --height=100 --title="Error" --text="Invalid Enum Number Value"
                rm -r "$tableName"
                create_Table $1
            fi

            enum_values=()
            for (( j=1; j<=enum_count; j++ )); do
                enum_value=$(zenity --entry --width=400 --height=100 --title="Create Table $tableName" --text="Enter Enum Value $j for Column $name")

                if [ $? -ne 0 ]; then
                    zenity --error --width=400 --height=100 --title="Error" --text="$tableName Creation Cancelled"
                    rm -r "$tableName"
                    create_Table $1
                fi

                enum_value=$(echo "$enum_value" | xargs)
                if [[ -z "$enum_value" ]]; then
                    zenity --error --width=400 --height=100 --title="Error" --text="Enum Value Cannot Be Empty"
                    rm -r "$tableName"
                    create_Table $1
                fi

                enum_values+=("$enum_value")
            done

            formatted_enum="{${enum_values[*]}}"
        fi

        data_types+=($data_type)
    done
    primary_key_col=$(zenity --list --width=400 --height=500 --title="Create Table $tableName" \
    --text="Select Primary Key Column" --column="Columns" "${columns[@]}")
    if [ $? -ne 0 ]; then
        zenity --error --width=400 --height=100 --title="Error" --text="$tableName Creation Cancelled"
        rm -r "$tableName"
        create_Table $1
    fi
    if [ -z "$primary_key_col" ]; then
        zenity --error --width=400 --height=100 --title="Error" --text="$tableName Creation Failed No Primary Key Selected"
        rm -r "$tableName"
        create_Table $1
    fi
    for(( i=0; i < numColumns; i++ )); do
        if [[ "${columns[$i]}" == "$primary_key_col" ]]; then
            primary_keys+=("y")
        else
            primary_keys+=("n")
        fi
    done

    

    for ((i = 0; i < numColumns; i++)); do
        formatted_value=""
        if [[ "${data_types[i]}" == "Enum" ]]; then
            formatted_value=":${formatted_enum}"
        fi

        echo "${columns[i]}:${data_types[i]}:${primary_keys[i]}:${unique[i]}:${nullable[i]}${formatted_value}" >> "$tableName/$tableName.md"
    done
    for (( i=0; i < numColumns; i++ )); do
        count=$(cut -d ':' -f 1 "$tableName/$tableName.md" | grep -i "^${columns[$i]}$" | wc -l)
        if [[ $count -gt 1 ]]; then
            zenity --error --width=400 --height=100 --title="Error" --text="Column Name Already Exists"
            rm -r "$tableName"
            create_Table $1
        fi
        
    done
    zenity --info --width=400 --height=100 --title="Success" --text="Table $tableName Created Successfully"
    Table_Menu $1
}

create_Table $1