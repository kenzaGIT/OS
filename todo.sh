# !/bin/bash


Tasks_List="tasks.txt"
id=0


get_id() {
   
    if [[ -e "$Tasks_List" ]]; then

        l_id=$(tail -n 1 "$Tasks_List" | cut -d'|' -f1)
      
        n_id=$((l_id + 1))
    else
   
        n_id=1
    fi
    echo "$n_id"
}


validate_time() {
    local input_time="$1"

    # Check if the time string is empty
    if [[ -z "$input_time" ]]; then
        echo "Error: Time is required."
        return 1
    fi

    # Validate the time format
    if ! [[ "$input_time" =~ ^([0-1][0-9]|2[0-3]):[0-5][0-9]$ ]]; then
        echo "Error: Invalid time format. Please use HH:MM."
        return 1
    fi

    return 0
}



validate_date() {
    local input_date="$1"
    
    
    if [[ -z "$input_date" ]]; then
        echo "Error: Due date is required."
        return 1
    fi

    local day=$(echo "$input_date" | cut -d'/' -f1)
    local month=$(echo "$input_date" | cut -d'/' -f2)
    local year=$(echo "$input_date" | cut -d'/' -f3)

   
    if ! [[ "$input_date" =~ ^[0-9]{2}/[0-9]{2}/[0-9]{4}$ ]]; then
        echo "Error: Invalid date format. Please use DD/MM/YYYY."
        return 1
    elif ((10#$day < 1 || 10#$day > 31)); then
        echo "Error: Invalid day. Day must be between 01 and 31."
        return 1
    elif ((10#$month < 1 || 10#$month > 12)); then
        echo "Error: Invalid month. Month must be between 01 and 12."
        return 1
    fi

    return 0
}



title_exist() {
    local input_title="$1"  

    
    if awk -F'|' -v title="$input_title" '
        $2 == title {  # Compare only the second field exactly with the title
            exit 1;  # Exit with 1 when a match is found
        }
    ' "$Tasks_List"; then
        return 1  
    else

        return 0 
    fi
}

create_task() {
    local title desc loc due time

    while true; do
        printf "Enter the task title (required): "
        read title
        if [[ -z "$title" ]]; then
            echo "Error: Title is required. Please enter a valid title."
        elif title_exist "$title"; then
            echo "Error: Task title '$title' already exists. Please enter a unique title."
        else
            break
        fi
    done

    printf "Enter the task description (optional, default='No Description'): "
    read desc
    if  [[ -z "$desc" ]]; then
      desc="No Description"
    fi
    printf "Enter the location (optional, default='No Location'): "
    read loc
    if [[ -z "$loc" ]] ; then
     loc="No Location"
    fi
 
    
    
    while true ; do
    printf "Enter the due date (required, format DD/MM/YYYY): "
    read due
    if [[ -z "$due" ]]; then
            echo "Error: date is required. Please enter a valid date."
    elif ! validate_date "$due"; then
       echo "Error: The date you entered is not valid. Please enter valid date."
    else
       break
    fi
  done



  while true ; do
    printf "Enter the time (required, format HH:MM): "
    read time
    if [[ -z "$time" ]]; then
            echo "Error: Time is required. Please enter a valid time."
    elif ! validate_time "$time"; then
       echo "Error: The time you entered is not valid. Please enter valid time."
    else
       break
    fi
  done

    local id=$(get_id)
    echo "$id|$title|$desc|$loc|$due|$time|not_done" >> "$Tasks_List"
    echo "New task created with id: $id"
}



update_task() {
    local task_title
    local task_exists=false

    while true; do
        echo "Enter the title of the task you want to update (or type 'exit' to return):"
        read task_title

        if [[ "$task_title" == "exit" ]]; then
            return
        fi

        task_exists=false
        local original_desc=""
        local original_loc=""
        local original_due=""
        local original_time=""
        local original_completed=""
        while IFS='|' read -r id title desc loc due time completed; do
            if [[ "$title" == "$task_title" ]]; then
                task_exists=true
                original_desc=$desc
                original_loc=$loc
                original_due=$due
                original_time=$time
                original_completed=$completed
                break
            fi
        done < "$Tasks_List"

        if [[ "$task_exists" == true ]]; then
            break
        else
            echo "Task titled '$task_title' not found. Please try again."
        fi
    done

    local updates=()

    local new_title
    while true; do
        echo "Enter the new title (press ENTER to skip):"
        read new_title
        if [[ -z "$new_title" ]]; then
            new_title=$task_title
            break
        elif ! title_exist "$new_title"; then
            break
        else
            echo "Error: Task title '$new_title' already exists. Please enter a unique title."
        fi
    done
    updates+=("title=$new_title")

    echo "Enter the new description (or press ENTER to keep existing):"
    read new_desc
    new_desc=$original_desc
    updates+=("desc=$new_desc")

    echo "Enter the new location (or press ENTER to keep existing):"
    read new_loc
    new_loc=$original_loc
    updates+=("loc=$new_loc")

    local new_due
    while true; do
        echo "Enter the new due date (format DD/MM/YYYY, or press ENTER to skip):"
        read new_due
        if [[ -z "$new_due" ]]; then
            new_due=$original_due
            break
        elif validate_date "$new_due"; then
            updates+=("due=$new_due")
            break
        else
            echo "Error: Date format is not valid. Please enter a valid date."
        fi
    done

    local new_time
    while true; do
        echo "Enter the new time (format HH:MM, press ENTER to skip):"
        read new_time
        if [[ -z "$new_time" ]]; then
            new_time=$original_time
            break
        elif validate_time "$new_time"; then
            updates+=("time=$new_time")
            break
        else
            echo "Error: Time format is not valid. Please enter a valid time."
        fi
    done
    
    

   echo "Has the task been completed? (yes/no, press ENTER to skip):"
read new_completed

if [[ -z "$new_completed" ]]; then
    new_completed=$original_completed 
elif [[ "$new_completed" == "yes" ]]; then
    new_completed="done"
else
    new_completed="not_done"
fi

updates+=("completed=$new_completed")  


    local temp_file=$(mktemp)
    while IFS='|' read -r id title desc loc due time completed; do
        if [[ "$title" == "$task_title" ]]; then
            echo "$id|$new_title|$new_desc|$new_loc|$new_due|$new_time|$new_completed" >> "$temp_file"
        else
            echo "$id|$title|$desc|$loc|$due|$time|$completed" >> "$temp_file"
        fi
    done < "$Tasks_List"

    mv "$temp_file" "$Tasks_List"
    echo "Task updated successfully."
}


   



delete_task() {
    local task_title
    local task_found=false

    while true; do
        echo "Enter the title of the task you want to delete (or type 'exit' to return):"
        read task_title

    
        if [[ "$task_title" == "exit" ]]; then
            return
        fi

        local temp_file=$(mktemp)
        task_found=false

        while IFS='|' read -r id title desc loc due completed; do
            if [[ "$title" == "$task_title" ]]; then
                task_found=true
                echo "Deleting task: $title"
                continue  
            fi
            echo "$id|$title|$desc|$loc|$due|$completed" >> "$temp_file"
        done < "$Tasks_List"

        
        if [[ "$task_found" == true ]]; then
            mv "$temp_file" "$Tasks_List"  
            echo "Task deleted successfully."
            break  
        else
            echo "Task titled '$task_title' not found. Please try again."
            rm "$temp_file"  
        fi
    done
}




show_task() {
    local task_title
    local task_found=false

    while true; do
        echo "Enter the title of the task you want to view (or type 'exit' to return):"
        read task_title

        if [[ "$task_title" == "exit" ]]; then
            return
        fi

        task_found=false

        while IFS='|' read -r id title desc loc due completed; do
            if [[ "$title" == "$task_title" ]]; then
                echo "Task ID: $id"
                echo "Title: $title"
                echo "Description: $desc"
                echo "Location: $loc"
                echo "Due Date: $due"
                echo "Completion Status: $completed"
                task_found=true
                break  
            fi
        done < "$Tasks_List"

        if [[ "$task_found" == true ]]; then
            break 
        else
            echo "Task titled '$task_title' not found. Please try again."
        fi
    done
}



complete_task() {
    local input_due

    
    while true; do
        read -p "Enter the due date for which you want to list tasks (required, format DD/MM/YYYY): " input_due
        if validate_date "$input_due"; then
            break
        fi
    done

    local completed_tasks=()
    local uncompleted_tasks=()

   
    while IFS='|' read -r id title desc loc due time status; do
        if [[ "$due" == "$input_due" ]]; then
            local task_info="ID: $id - Title: $title, Description: $desc, Location: $loc, Due: $due, Time: $time, Status: $status"
            if [[ "$status" == "done" ]]; then
                completed_tasks+=("$task_info")
            elif [[ "$status" == "not_done" ]]; then
                uncompleted_tasks+=("$task_info")
            fi
        fi
    done < "$Tasks_List"

    echo "Completed Tasks:"
    if [ ${#completed_tasks[@]} -eq 0 ]; then
        echo "None"
    else
        for task in "${completed_tasks[@]}"; do
            echo "$task"
        done
    fi

    echo ""
    echo "Uncompleted Tasks:"
    if [ ${#uncompleted_tasks[@]} -eq 0 ]; then
        echo "None"
    else
        for task in "${uncompleted_tasks[@]}"; do
            echo "$task"
        done
    fi
}

display_today_tasks() {
    local today=$(date '+%d/%m/%Y')  
    local completed_tasks=()
    local uncompleted_tasks=()

    while IFS='|' read -r id title desc loc due time status; do
        due=$(echo "$due" | xargs) 
        if [[ "$due" == "$today" ]]; then
            local task_info="ID: $id - Title: $title, Description: $desc, Location: $loc, Due: $due, Time: $time, Status: $status"
            if [[ "$status" == "done" ]]; then
                completed_tasks+=("$task_info")
            elif [[ "$status" == "not_done" ]]; then
                uncompleted_tasks+=("$task_info")
            fi
        fi
    done < "$Tasks_List"

    echo "Completed Tasks for Today ($today):"
    if [ ${#completed_tasks[@]} -eq 0 ]; then
        echo "None"
    else
        for task in "${completed_tasks[@]}"; do
            echo "$task"
        done
    fi

    echo ""
    echo "Uncompleted Tasks for Today ($today):"
    if [ ${#uncompleted_tasks[@]} -eq 0 ]; then
        echo "None"
    else
        for task in "${uncompleted_tasks[@]}"; do
            echo "$task"
        done
    fi
}


list_tasks() {
    echo "Listing all tasks by ID and Title:"
    if [[ ! -f "$Tasks_List" ]] || ! [[ -s "$Tasks_List" ]]; then
        echo "No tasks found."
        return
    fi

    while IFS='|' read -r id title _; do  # Using underscore (_) to ignore other fields
        echo "Task ID: $id - Title: $title"
    done < "$Tasks_List"
}



show_usage() {
    echo "Commands:"
    echo "    create - Add a new task"
    echo "    update - Modify an existing task"
    echo "    delete - Remove a task"
    echo "    list   - List all tasks"
    echo "    show   - Show details of a specific task"
    echo "    complete - List the completed and uncompleted tasks of a given day"
    echo "    todo   - Display today's tasks"
    echo "    help   - Display this help message"
    echo "    exit   - Exit the script"
}

if [[ $# -gt 0 ]]; then
    if [[ "$1" == "todo" ]]; then
        display_today_tasks
        exit 0
    else
        echo "Invalid argument: $1"
        echo "If you need help, run './todo.sh' without any arguments."
        exit 1
    fi
fi

echo "Welcome to Todo Script!"
show_usage

while true; do
    echo "Enter a command:"
    read command

    case $command in
        create)
            create_task
            ;;
        update)
            update_task
            ;;
        delete)
            delete_task
            ;;
        list)
            list_tasks
            ;;
        show)
            show_task
            ;;
        complete)
            complete_task
            ;;
        todo)
            display_today_tasks
            ;;
        help)
            show_usage
            ;;
        exit)
            echo "Exiting the script."
            break
            ;;
        *)
            echo "Invalid command. Type 'help' for a list of valid commands."
            ;;
    esac
done
    
}
