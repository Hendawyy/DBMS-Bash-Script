# 🗄️ Bash Script Database Engine (DBE)

## 📌 Table of Contents

- [🗄️ Bash Script Database Engine (DBE)](#️-bash-script-database-engine-dbe)
  - [📌 Table of Contents](#-table-of-contents)
  - [📚 About the Project](#-about-the-project)
  - [🗂 Project Structure](#-project-structure)
  - [🔧 Installation](#-installation)
  - [🚀 Usage](#-usage)
  - [📝 Available Commands](#-available-commands)
    - [📁 Database Management](#-database-management)
    - [📄 Table Management](#-table-management)
  - [📚 SQL Command Reference](#-sql-command-reference)
  - [👨‍💻 Contributors](#-contributors)

---

## 📚 About the Project

This is a **Bash Script-based Database Engine (DBE)** that allows users to create, manage, and manipulate databases using shell scripting. It provides:

- **CLI Mode** for SQL-like commands.
- **GUI Mode** for intuitive database management.
- **Seamless Switching** between GUI and CLI without exiting the database session, enhancing user experience.

---

## 🗂 Project Structure

```.
├── Databases               # Stores databases and tables as directories
├── DatabaseScripts         # Scripts for creating, listing, renaming, and deleting databases
├── TableScripts            # Scripts for managing tables and executing SQL commands
│   ├── GUI_Scripts         # GUI-based table management scripts
│   ├── SQL_Scripts         # SQL-based operations on tables
├── helper.sh               # Helper functions for validation and utilities
├── DB.sh                   # Main script to launch the DBE
├── DataRetrievalHelper.sh   # Script for fetching and handling table data
└── README.md               # Documentation for the project
```

---

## 🔧 Installation

1. Clone the repository:

   ```bash
   git clone https://github.com/ahmeedusamaa/DBMS-Bash-Script.git
   ```

2. Navigate to the project directory:

   ```bash
   cd DBMS-Bash-Script
   ```

3. Grant execution permissions:

   ```bash
   chmod +x DB.sh
   ```

---

## 🚀 Usage

To start the Database Engine, run:

```bash
./DB.sh
```

This will launch an interactive menu to manage databases and tables.

---

## 📝 Available Commands

### 📁 Database Management

- **Create Database**: Create a new database.
- **List Databases**: Show all available databases.
- **Rename Database**: Rename an existing database.
- **Drop Database**: Delete a database.

### 📄 Table Management

- **Create Table**: Define a table with column names and types.
- **List Tables**: View all tables in the selected database.
- **Drop Table**: Delete a table.
- **Insert Data**: Insert records into a table.
- **Select Data**: Retrieve records with conditions.
- **Update Data**: Modify records in a table.
- **Delete Data**: Remove records based on conditions.

---

## 📚 SQL Command Reference

| **Operation**      | **SQL Command Example**                                                                                                |
| ------------------ | ---------------------------------------------------------------------------------------------------------------------- |
| **Delete Record**  | `DELETE FROM table_name WHERE id = 1;`                                                                                 |
| **Drop Table**     | `DROP TABLE table_name;`                                                                                               |
| **Update Record**  | `UPDATE table_name SET name='Bob' WHERE id = 1;`                                                                       |
| **Select All**     | `SELECT * FROM table_name;`  `SELECT all FROM table_name;`                                                             |
| **Select Columns** | `SELECT id, name FROM table_name;`                                                                                     |
| **Insert Record**  | `INSERT INTO new_table_1 VALUES (24, 'Aya', 30, 'F', 22.3, 'aya@gmail.com', 'mypassword', '01122334455', '95/05/15');` |
| **Insert Simple**  | `INSERT INTO meezo VALUES (24, 'Messi', 'F');`                                                                         |

---

## 👨‍💻 Contributors

- **Ahmed Osama** - [Linkedin](https://www.linkedin.com/in/ahmed-osama-788a6b1ab/)
- **Seif Hendawy** - [Linkedin](https://www.linkedin.com/in/seif-hendawy-3995561a8/)
