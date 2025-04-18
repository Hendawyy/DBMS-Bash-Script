#!/bin/bash
source ../../helper.sh

function Update_Table(){
    
    dbName=$1
    tableName=$2
    DBsPath="../../Databases/$dbName"
    tableDataPath="$DBsPath/$tableName/$tableName"
    metaDataPath="$DBsPath/$tableName/$tableName.md"

    Column_Names=$(awk -F: 'NR>3 {print $1}' $metaDataPath)
    Selected_Column=$(zenity --list --width=400 --height=600 \
    --title="List of Columns in $tableName" --text="Choose a Column To Update:" \
    --column="Columns" $Column_Names)
    if [ $? -eq 1 ]; then
        zenity --info --width=400 --height=100 --title="Info" --text="Update Table Operation Cancelled"
        Table_Menu $dbName
    fi
    if [ -z $Selected_Column ]; then
        zenity --error --text="No Column Selected"
        Update_Table $dbName $tableName
    fi
    Selected_Column_Number=$(awk -F: -v selected_col="$Selected_Column" 'NR>3 && $1 == selected_col {print NR-3}' "$metaDataPath")
    DataType=$(awk -F: -v colName=$Selected_Column 'NR>3 {if($1==colName) print $2}' $metaDataPath)
    UpdateValue=$(zenity --entry --title="Update Column" --text="Enter New Value for $Selected_Column($DataType):")
    if [ $? -eq 1 ]; then
        zenity --info --width=400 --height=100 --title="Info" --text="Update Table Operation Cancelled"
        Table_Menu $dbName
    fi
    if [ -z $UpdateValue ]; thenstudents
        zenity --error --text="No Value Entered"
        Update_Table $dbName $tableName
    fi
    UpdateValuez=()
    UpdateValuez+=($UpdateValue)
    if [[ "$DataType" == "Enum" ]]; then
        if ! validate_enum "$UpdateValue" "$Selected_Column_Number" "$tableName" "GUI"; then
            zenity --error --text="Invalid input: $UpdateValue, Please enter a valid Enum Value."
            Update_Table $dbName $tableName
        fi
    else
        if ! validate_input "${UpdateValuez[@]}" "$DataType"; then
            Update_Table $dbName $tableName
        fi
    fi
    ColumnCondition=$(zenity --list --width=400 --height=600 \
    --title="Columns in $tableName" --text="Choose a Column To Filter On:" \
    --column="Columns" $Column_Names)
    if [ $? -eq 1 ]; then
        zenity --info --width=400 --height=100 --title="Info" --text="Update Table Operation Cancelled"
        Table_Menu $dbName
    fi
    if [ -z $ColumnCondition ]; then
        zenity --error --text="No Column Selected"
        Update_Table $dbName $tableName
    fi
    DataTypeCondColumn=$(awk -F: -v colName=$ColumnCondition 'NR>3 {if($1==colName) print $2}' $metaDataPath)
    if [[ "$DataTypeCondColumn" == "ID--Int--Auto--Inc." || "$DataTypeCondColumn" == "INT" || "$DataTypeCondColumn" == "Double" || "$DataTypeCondColumn" == "Date" || "$DataTypeCondColumn" == "current_timestamp" ]]; then
        operators=("==" "!=" ">" "<" ">=" "<=")
    else
        operators=("==" "!=")
    fi
    
    Selected_Operator=$(zenity --list --width=400 --height=600 \
    --title="Operators" --text="Choose an Operator to use in your condition:" \
    --column="Operators" "${operators[@]}")
    
    if [ $? -eq 1 ]; then
        zenity --info --width=400 --height=100 --title="Info" --text="Update Table Operation Cancelled"
        Table_Menu $dbName
    fi
    if [ -z $Selected_Operator ]; then
        zenity --error --text="No Operator Selected"
        Update_Table $dbName $tableName
    fi

    Condition_Value=$(zenity --entry --title="Enter Condition Value" --text="Enter Value to Compare with $ColumnCondition($DataTypeCondColumn):")
    if [ $? -eq 1 ]; then
        zenity --info --width=400 --height=100 --title="Info" --text="Update Table Operation Cancelled"
        Table_Menu $dbName
    fi
    if [ -z $Condition_Value ]; then
        zenity --error --text="No Value Entered"
        Update_Table $dbName $tableName
    fi
    Column_Number_filter=$(awk -F: -v selected_col="$ColumnCondition" 'NR>3 && $1 == selected_col {print NR-3}' "$metaDataPath")

    Filter_AND_Update  "$tableDataPath" "$metaDataPath" "$Selected_Column_Number" "$Column_Number_filter" "$Selected_Operator" "$Condition_Value" "$UpdateValue"

    Table_Menu $dbName
}

Update_Table $1 $2