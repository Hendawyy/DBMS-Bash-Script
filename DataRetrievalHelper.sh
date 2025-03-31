#!bin/bash
source ../../TableScripts/GUI_Scripts/Table_Header.sh
function Select_Without_Condition(){
    type=$1
    dbName=$2
    tableName=$3
    if [ $type == "All(*)" ]; then
        Select_All $dbName $tableName
    elif [ $type == "Columns" ]; then
        Select_Columns $dbName $tableName
    else
        zenity --error --text="Invalid Type"
        source ../../TableScripts/GUI_Scripts/select_from_Table.sh $dbName $tableName
    fi
}

function Select_With_Condition(){
    type=$1
    dbName=$2
    tableName=$3
    echo "Tables With: "$3
    if [ $type == "All(*)" ]; then
        Select_All_Cond $dbName $tableName
    elif [ $type == "Columns" ]; then
        Select_Columns_Cond $dbName $tableName
    else
        zenity --error --text="Invalid Type"
        source ../../TableScripts/GUI_Scripts/select_from_Table.sh $dbName $tableName
    fi
}

function retrieve_table_data_select_all(){
    dbName=$1
    selectedTable=$2

    TableDataPath="../$dbName/$selectedTable/$selectedTable"
    metadataPath="../$dbName/$selectedTable/$selectedTable.md"
    headers=$(awk -F: 'NR>3 {print $1}' "$metadataPath")
    numCols=$(awk -F: 'NR==2 {print $2}' "$metadataPath")
    primaryKey=$(awk -F':' '$3 == "y" { print $1 }' "$metadataPath")

    uppercaseTable=$(echo "$selectedTable" | awk '{print toupper($0)}')
    uppercasePrimaryKey=$(echo "$primaryKey" | awk '{print toupper($0)}')

    formatted_data="${TABLE_HEADER//TABLE_NAME_PLACEHOLDER/$uppercaseTable}"
    formatted_data="${formatted_data//PRIMARY_KEY_PLACEHOLDER/$uppercasePrimaryKey}"

    for header in $headers; do
        formatted_data+="<th>$header</th>"
    done

    formatted_data+="</tr>"

    while IFS=":" read -r -a fields; do
        formatted_data+="<tr>"

        for ((i = 0; i < $numCols; i++)); do
            formatted_data+="<td>${fields[i]}</td>"
        done 

        formatted_data+="</tr>"
    done < "$TableDataPath"

    formatted_data+="</table>
    </center>
    </body>
    </html>"

    echo "$formatted_data"
}

function Select_All(){
    dbName=$1
    table=$2
    selectedTable=$table

    if [ -z "$selectedTable" ]; then
        zenity --error --text="No Table Selected"
        source ../../TableScripts/GUI_Scripts/select_from_Table.sh $dbName $selectedTable
    fi

    formatted_data=$(retrieve_table_data_select_all "$dbName" "$selectedTable")

    zenity --text-info --title="$selectedTable Table" --width=1080 --height=950 \
        --html --filename=<(echo "$formatted_data") 2>>/dev/null

    Table_Menu $dbName
}

function retrieve_selected_columns(){
    dbName=$1
    selectedTable=$2
    selectedColumns=("${@:3}") 

    TableDataPath="../$dbName/$selectedTable/$selectedTable"
    metadataPath="../$dbName/$selectedTable/$selectedTable.md"
    primaryKey=$(awk -F':' '$3 == "y" { print $1 }' "$metadataPath")
    headers=$(awk -F: 'NR>3 {print $1}' "$metadataPath")
    IFS=$'\n' read -r -d '' -a headerArray <<< "$headers"

    selectedIndices=()
    for selected in "${selectedColumns[@]}"; do
        for i in "${!headerArray[@]}"; do
            if [[ "${headerArray[i]}" == "$selected" ]]; then
                selectedIndices+=("$((i+1))")
                break
            fi
        done
    done

    uppercaseTable=$(echo "$selectedTable" | awk '{print toupper($0)}')
    uppercasePrimaryKey=$(echo "$primaryKey" | awk '{print toupper($0)}')

    formatted_data="${TABLE_HEADER//TABLE_NAME_PLACEHOLDER/$uppercaseTable}"
    formatted_data="${formatted_data//PRIMARY_KEY_PLACEHOLDER/$uppercasePrimaryKey}"

    for header in "${selectedColumns[@]}"; do
        formatted_data+="<th>$header</th>"
    done
    formatted_data+="</tr>"

    while IFS= read -r line; do
        IFS=":" read -ra fields <<< "$line"

        formatted_data+="<tr>"
        for index in "${selectedIndices[@]}"; do
            formatted_data+="<td>${fields[index-1]}</td>"
        done
        formatted_data+="</tr>"
    done < "$TableDataPath"

    formatted_data+="</table></body></html>"

    echo "$formatted_data"
}

function Select_Columns(){
    dbName=$1
    tables=$2

    selectedTable=$tables

    if [ $? -eq 1 ] || [ -z "$selectedTable" ]; then
        zenity --error --text="No Table Selected"
        Table_Menu $dbName
    fi

    metadataPath="../$dbName/$selectedTable/$selectedTable.md"
    headers=$(awk -F: 'NR>3 {print $1}' "$metadataPath")
    IFS=$'\n' read -r -d '' -a headerArray <<< "$headers"

    checklist=()
    for header in "${headerArray[@]}"; do
        checklist+=("FALSE" "$header")
    done

    SelectedHeaders=$(zenity --list --checklist --width=400 --height=600 \
    --title="Select Columns" --text="Choose Columns To Select:" \
    --column="Select" --column="Columns" "${checklist[@]}")

    if [ $? -eq 1 ] || [ -z "$SelectedHeaders" ]; then
        zenity --error --text="No Columns Selected"
        Table_Menu $dbName
    fi

    IFS="|" read -r -a selectedHeadersArr <<< "$SelectedHeaders"

    formatted_data=$(retrieve_selected_columns "$dbName" "$selectedTable" "${selectedHeadersArr[@]}")

    zenity --text-info --title="$selectedTable Table" --width=1080 --height=950 \
        --html --filename=<(echo "$formatted_data") 2>>/dev/null

    Table_Menu $dbName
}

function retrieve_filtered_data() {
    dbName=$1
    selectedTable=$2
    columnName=$3
    operator=$4
    filterValue=$5
    functionName="SELECT"

    TableDataPath="../$dbName/$selectedTable/$selectedTable"
    metadataPath="../$dbName/$selectedTable/$selectedTable.md"

    headers=$(awk -F: 'NR>3 {print $1}' "$metadataPath")
    numCols=$(awk -F: 'NR==2 {print $2}' "$metadataPath")
    primaryKey=$(awk -F':' '$3 == "y" { print $1 }' "$metadataPath")

    ColumnIndex=$(awk -F: -v selected_col="$columnName" 'NR>3 && $1 == selected_col {print NR-3}' "$metadataPath")

    filter_matching "$TableDataPath" "$ColumnIndex" "$operator" "$filterValue" "matchingRows.tmp" "$functionName"

    numberOfMatchingRows=$(wc -l < matchingRows.tmp)
    if [ "$numberOfMatchingRows" -eq 0 ]; then
        zenity --info --width=400 --height=100 --title="Info" --text="No Rows Matched the Condition"
        source ../../TableScripts/GUI_Scripts/select_from_Table.sh $dbName $selectedTable
    fi

    uppercaseTable=$(echo "$selectedTable" | awk '{print toupper($0)}')
    uppercasePrimaryKey=$(echo "$primaryKey" | awk '{print toupper($0)}')

    formatted_data="${TABLE_HEADER//TABLE_NAME_PLACEHOLDER/$uppercaseTable}"
    formatted_data="${formatted_data//PRIMARY_KEY_PLACEHOLDER/$uppercasePrimaryKey}"

    for header in $headers; do
        formatted_data+="<th>$header</th>"
    done
    formatted_data+="</tr>"

    while IFS= read -r line; do
        formatted_data+="<tr>"
        IFS=':' read -r -a row <<< "$line"
        for value in "${row[@]}"; do
            formatted_data+="<td>$value</td>"
        done
        formatted_data+="</tr>"
    done < matchingRows.tmp

    formatted_data+="</table></body></html>"
    
    rm matchingRows.tmp
    echo "$formatted_data"
}

function Select_All_Cond() {
    dbName=$1
    tables=$2

    selectedTable=$tables

    metadataPath="../$dbName/$selectedTable/$selectedTable.md"
    headers=$(awk -F: 'NR>3 {print $1}' "$metadataPath")

    Selected_Column=$(zenity --list --width=400 --height=600 \
        --title="Select Column" --text="Choose a Column To Filter By:" \
        --column="Columns" $headers)

    if [ $? -eq 1 ] || [ -z "$Selected_Column" ]; then
        zenity --error --text="No Column Selected"
        source ../../TableScripts/GUI_Scripts/select_from_Table.sh "$dbName" $selectedTable
        return
    fi

    DataTypeCondColumn=$(awk -F: -v colName="$Selected_Column" 'NR>3 && $1==colName {print $2}' "$metadataPath")

    if [[ "$DataTypeCondColumn" == "ID--Int--Auto--Inc." || \
          "$DataTypeCondColumn" == "INT" || \
          "$DataTypeCondColumn" == "Double" || \
          "$DataTypeCondColumn" == "Date" || \
          "$DataTypeCondColumn" == "current_timestamp" ]]; then
        operators=("==" "!=" ">" "<" ">=" "<=")
    else
        operators=("==" "!=")
    fi

    SelectedOperator=$(zenity --list --width=400 --height=600 \
        --title="Select Operator" --text="Choose an Operator:" \
        --column="Operators" "${operators[@]}")

    if [ $? -eq 1 ] || [ -z "$SelectedOperator" ]; then
        zenity --error --text="No Operator Selected"
        source ../../TableScripts/GUI_Scripts/select_from_Table.sh "$dbName" $selectedTable
        return
    fi

    FilterValue=$(zenity --entry --width=400 --title="Filter Value" \
        --text="Enter Value to Filter By For Column $Selected_Column ($DataTypeCondColumn):")

    if [ $? -eq 1 ] || [ -z "$FilterValue" ]; then
        zenity --error --text="No Value Entered"
        source ../../TableScripts/GUI_Scripts/select_from_Table.sh "$dbName" $selectedTable
        return
    fi

    formatted_data=$(retrieve_filtered_data "$dbName" "$selectedTable" "$Selected_Column" "$SelectedOperator" "$FilterValue")

    if [ -n "$formatted_data" ]; then
        zenity --text-info --title="$selectedTable Table" --width=1080 --height=950 \
            --html --filename=<(echo "$formatted_data") 2>>/dev/null
    fi

    Table_Menu "$dbName"
}

function Retrieve_Filtered_Data_Cond() {
    TableDataPath=$1
    ColumnIndex=$2
    SelectedOperator=$3
    FilterValue=$4
    functionName="SELECT"
    shift 4

    selectedHeaders=()
    while [[ "$1" != "|" ]]; do
        selectedHeaders+=("$1")
        shift
    done
    shift
    selectedIndices=("$@")

    filter_matching "$TableDataPath" "$ColumnIndex" "$SelectedOperator" "$FilterValue" "matchingRows.tmp" "$functionName"

    numberOfMatchingRows=$(wc -l < matchingRows.tmp)
    if [ "$numberOfMatchingRows" -eq 0 ]; then
        zenity --info --width=400 --height=100 --title="Info" --text="No Rows Matched the Condition"
        return
    fi
    primaryKey=$(awk -F':' '$3 == "y" { print $1 }' "$TableDataPath.md")

    uppercaseTable=$(echo "$selectedTable" | awk '{print toupper($0)}')
    uppercasePrimaryKey=$(echo "$primaryKey" | awk '{print toupper($0)}')

    formatted_data="${TABLE_HEADER//TABLE_NAME_PLACEHOLDER/$uppercaseTable}"
    formatted_data="${formatted_data//PRIMARY_KEY_PLACEHOLDER/$uppercasePrimaryKey}"

    for header in "${selectedHeaders[@]}"; do
        formatted_data+="<th>$header</th>"
    done
    formatted_data+="</tr>"

    while IFS= read -r line; do
        IFS=":" read -ra fields <<< "$line"
        formatted_data+="<tr>"
        for index in "${selectedIndices[@]}"; do
            formatted_data+="<td>${fields[index-1]}</td>"
        done
        formatted_data+="</tr>"
    done < matchingRows.tmp

    formatted_data+="</table></body></html>"

    rm matchingRows.tmp

    zenity --text-info --title="Filtered Data" --width=1080 --height=950 \
        --html --filename=<(echo "$formatted_data") 2>>/dev/null
}

function Select_Columns_Cond() {
    dbName=$1
    tables=$2
    selectedTable=$tables


    TableDataPath="../$dbName/$selectedTable/$selectedTable"
    metadataPath="../$dbName/$selectedTable/$selectedTable.md"
    headers=$(awk -F: 'NR>3 {print $1}' "$metadataPath")
    IFS=$'\n' read -r -d '' -a headerArray <<< "$headers"

    checklist=()
    for header in "${headerArray[@]}"; do
        checklist+=("FALSE" "$header")
    done

    SelectedHeaders=$(zenity --list --checklist --width=400 --height=600 \
        --title="Select Columns" --text="Choose Columns To Select:" \
        --column="Select" --column="Columns" "${checklist[@]}")

    if [ $? -eq 1 ] || [ -z "$SelectedHeaders" ]; then
        zenity --error --text="No Columns Selected"
        Table_Menu "$dbName"
    fi

    IFS="|" read -r -a selectedHeadersArr <<< "$SelectedHeaders"
    selectedIndices=()
    for selected in "${selectedHeadersArr[@]}"; do
        for i in "${!headerArray[@]}"; do
            if [[ "${headerArray[i]}" == "$selected" ]]; then
                selectedIndices+=("$((i+1))")
                break
            fi
        done
    done

    Selected_Column=$(zenity --list --width=400 --height=600 \
        --title="Select Column" --text="Choose a Column to Filter By:" \
        --column="Columns" "${selectedHeadersArr[@]}")

    if [ $? -eq 1 ] || [ -z "$Selected_Column" ]; then
        zenity --error --text="No Column Selected"
        Table_Menu "$dbName"
    fi

    DataTypeCondColumn=$(awk -F: -v colName="$Selected_Column" 'NR>3 && $1==colName {print $2}' "$metadataPath")

    if [[ "$DataTypeCondColumn" == "ID--Int--Auto--Inc." || "$DataTypeCondColumn" == "INT" || "$DataTypeCondColumn" == "Double" || "$DataTypeCondColumn" == "Date" || "$DataTypeCondColumn" == "current_timestamp" ]]; then
        operators=("==" "!=" ">" "<" ">=" "<=")
    else
        operators=("==" "!=")
    fi

    SelectedOperator=$(zenity --list --width=400 --height=600 \
        --title="Select Operator" --text="Choose an Operator:" \
        --column="Operators" "${operators[@]}")

    if [ $? -eq 1 ] || [ -z "$SelectedOperator" ]; then
        zenity --error --text="No Operator Selected"
        Table_Menu "$dbName"
    fi

    FilterValue=$(zenity --entry --width=400 --title="Filter Value" \
        --text="Enter Value to Filter By For Column $Selected_Column ($DataTypeCondColumn):")

    if [ $? -eq 1 ] || [ -z "$FilterValue" ]; then
        zenity --error --text="No Value Entered"
        Table_Menu "$dbName"
    fi

    ColumnIndex=$(awk -F: -v selected_col="$Selected_Column" 'NR>3 && $1 == selected_col {print NR-3}' "$metadataPath")

    Retrieve_Filtered_Data_Cond "$TableDataPath" "$ColumnIndex" "$SelectedOperator" "$FilterValue" "${selectedHeadersArr[@]}" "|" "${selectedIndices[@]}"
    Table_Menu "$dbName"
}
