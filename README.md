Task Management Script

This Bash script provides a simple command-line tool for managing tasks. It allows users to create, update, delete, list, and view tasks. Each task is assigned a unique ID and can include details such as title, description, location, due date, and time.

Features
Create a task: Add new tasks with details such as title, description, location, due date, and time.
Update a task: Modify details of an existing task.
Delete a task: Remove an existing task from the list.
List tasks: Display all tasks with their ID and title.
Show task details: View complete details of a specific task.
Task completion check: List all tasks for a specified date, showing which tasks are completed and which are not

Installation
To use this script, clone this repository or download the todo.sh file to your local machine. Ensure that you have permissions to execute the script.

git clone https://github.com/yourUsername/yourRepository.git
cd yourRepository
chmod +x todo.sh

Usage

Run the script using the following command from your terminal:
./todo.sh

Upon execution, the script will display a list of available commands:

Welcome to Todo Script!
Commands:
    create - Add a new task
    update - Modify an existing task
    delete - Remove a task
    list   - List all tasks
    show   - Show details of a specific task
    complete - List the completed and uncompleted tasks of a given day
    help   - Display this help message
    exit   - Exit the script
Enter a command:

Commands
create: Follow the on-screen prompts to enter task details.
update: Enter the title of the task you want to update and follow the prompts to modify its details.
delete: Enter the title of the task you wish to delete.
list: This command will list all tasks by ID and title.
show: Enter the title of the task to view its full details.
complete: Enter a date to see tasks due on that day and their completion status.
todo: Displays all tasks for today.
help: Displays the list of available commands.
exit: Exits the script.

Configuration
No additional configuration is required to start using this script. Make sure that the todo.sh file is located in a directory where you have write permissions, as it needs to create and modify the tasks.txt file to store task details.

Contributions
Contributions are welcome. Please fork the repository and submit a pull request with your enhancements.

License
This script is open-sourced software licensed under the MIT license.

