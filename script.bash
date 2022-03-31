while getopts u: flag
do
    case "${flag}" in
        u) user=${OPTARG};;
    esac
done

if [ -z "$user" ];
  then processes=$(ps aux --sort=user | awk '{ if(NR!=1) print $1, $2, $3, $4, $11}');
  else processes=$(ps u -u $user | awk '{ if(NR!=1) print $1, $2, $3, $4, $11}');
fi

readarray -t processes < <(echo "$processes")

date=$(date +%F)
time=$(date +%T)
timestamp=$(date +%s)

log_folder="process-logs-$date-$timestamp"
mkdir $log_folder

echo -e "Today is: $date\nCurrent time: $time\n"
for process_line in "${processes[@]}"
do
  # 1 - USER, 2 - PID, 3 - CPU, 4 - MEM, 5 - PNAME
  readarray -d " " -t attributes < <(echo "$process_line")
  filepath="$PWD/$log_folder/${attributes[0]}-process-log-$date-$timestamp.log"

  if [[ ! -f "$filepath" ]]
  then
    echo -e "$date\n$time" > "$filepath"
    log_file_paths+=("$filepath")
  fi
  for attribute in "${attributes[@]:1}"
  do
    echo "$attribute" >> "$filepath"
  done
done

echo -e "Logs formed in DIR: $log_folder\nPATH: $PWD/$log_folder"
for file_path in "${log_file_paths[@]}"
do
  echo $(basename "$file_path") #dirname for directory
  echo "Line count: $(wc -l < "$file_path")"
done

echo -e "\nAll of the formed logs will be deleted! Path: $PWD/$log_folder"
read -p "Press any key to remove created files..." 
rm -r "$PWD/$log_folder"
