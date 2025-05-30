#!/bin/bash
#--------------------------#
# What this version fixes:
# 	1. tput clear, clears the entire page and redoes the animation. Looks distracting and a little jarring at times
#
# Needs to be fixed:
# 	1. Updates the art and progress bar line by line, needs to open in a new page
# 	2. Colour coding for the progress bar
#--------------------------#


# Character Definitions
blipsy_left='
 ,_/\\____/\\_,
( o      o  )
| -  ^  -   |         
 \\_||___||_/ 
   ||   ||   
'

blipsy_right='
 ,_/\\____/\\_,
(   o     o )
|  -  ^  -  |
 \\_||___||_/
   ||   ||  
'

format_time() {
  local seconds="$1"
  local hours=$((seconds / 3600))
  local minutes=$(((seconds % 3600) / 60))
  local secs=$((seconds % 60))
  printf "%02d:%02d:%02d" "$hours" "$minutes" "$secs"
}

move_cursor_up() {
  local lines="$1"
  printf "\e[%sA" "$lines"
}

run_timer() {
  local label="$1"
  local seconds="$2"
  local no_art="$3"
  local start=$(date +%s)
  local end=$((start + seconds))
  local flip=0
  local previous_output=""

  while (( $(date +%s) < end )); do
    local elapsed=$(( $(date +%s) - start ))
    local remaining=$((end - $(date +%s)))
    local progress_bar=$(printf '%*s' "$((elapsed * 100 / seconds))" | sed 's/ /#/g')$(printf '%*s' "$((100 - elapsed * 100 / seconds))" | sed 's/ /-/g')
    local current_output=""

    if [[ "$no_art" -eq 0 ]]; then
      if [[ "$flip" -eq 0 ]]; then
        current_output="$blipsy_left\n"
        flip=1
      else
        current_output="$blipsy_right\n"
        flip=0
      fi
    fi
    current_output+="\e[1;35m$label\e[0m [\e[36m$progress_bar\e[0m] \e[32mRemaining: $(format_time "$remaining")\e[0m"

    # Move cursor up by the number of lines in the previous output
    local previous_lines=$(echo "$previous_output" | wc -l)
    if [[ "$previous_lines" -gt 0 ]]; then
      move_cursor_up "$previous_lines"
    fi

    echo "$current_output"
    previous_output="$current_output"

    sleep 0.5
  done

  # Clear the last output
  local last_lines=$(echo "$previous_output" | wc -l)
  if [[ "$last_lines" -gt 0 ]]; then
    move_cursor_up "$last_lines"
    for i in $(seq 1 "$last_lines"); do
      echo -ne "$(tput el)\r" # Clear the current line and move cursor to the beginning
    done
  fi
  tput bel
}

blipsy_pomodoro() {
  local no_art="$1"
  local cycles="$2"
  local focus_duration="$3"
  local short_break="$4"
  local long_break="$5"
  local focus_message="$6"
  local short_break_message="$7"
  local long_break_message="$8"

  for ((cycle=1; cycle<=cycles; cycle++)); do
    run_timer "$focus_message (Cycle $cycle/$cycles)" "$focus_duration" "$no_art"

    if [[ "$cycle" -lt "$cycles" ]]; then
      run_timer "$short_break_message" "$short_break" "$no_art"
    else
      run_timer "$long_break_message" "$long_break" "$no_art"
    fi
  done

  if [[ "$no_art" -eq 0 ]]; then
    echo -e "\e[1;35m🎉 ,_/\\____/\\_,\e[0m"
    echo -e "\e[1;35m🎉( ^   o   ^  )\e[0m"
    echo -e "\e[1;35m🎉| PARTY TIME |\e[0m"
    echo -e "\e[1;35m🎉 \\__n___n__/\e[0m"
  fi
  echo -e "\n\e[1;32m✅ All cycles complete! Take a victory nap 💤\e[0m"
}

run() {
  local cycles="${1:-4}"
  local focus_secs="${2:-1500}"
  local short_break_secs="${3:-300}"
  local long_break_secs="${4:-900}"
  local focus_message="${5:-Focus Time}"
  local short_break_message="${6:-Go Relax}"
  local long_break_message="${7:-Have a nice break}"
  local art="${8:-true}"
  local no_art=1
  if [[ "$art" == "true" ]]; then
    no_art=0
  fi

  blipsy_pomodoro "$no_art" "$cycles" "$focus_secs" "$short_break_secs" "$long_break_secs" "$focus_message" "$short_break_message" "$long_break_message"
}

demo() {
  run 2 10 5 8 "Demo Focus" "Quick Chill" "Demo Nap" true
}

# Main execution based on arguments (mimicking typer)
if [[ "$1" == "run" ]]; then
  run "$2" "$3" "$4" "$5" "$6" "$7" "$8" "$9"
elif [[ "$1" == "demo" ]]; then
  demo
else
  echo "Usage: $0 (run [cycles] [focus_secs] [short_break_secs] [long_break_secs] [focus_message] [short_break_message] [long_break_message] [art]) | demo"
fi
