#!/usr/bin/env bash
# nmap_menu.sh
# Interactive Nmap menu with toggles, value‑sets, and NSE support.

# Requires Bash 4+
if ((BASH_VERSINFO[0] < 4)); then
  echo "Bash 4+ is required." >&2
  exit 1
fi

### --- Global State ---
declare -A FLAGS           # boolean flags
declare -a SCAN_TYPES      # selected scan types (with descriptions)
declare -A VALUES          # options with values (ports,timing,output)
declare -a NSE_CATEGORIES  # selected NSE categories
declare -a NSE_SCRIPTS     # selected NSE scripts
declare -A NSE_ARGS        # script args
TARGETS=""

# defaults
FLAGS=( [n]=false [6]=false [r]=false [reason]=false )
VALUES=( [ports]="1-1000" [timing]="-T3" [output_format]="" )
ALL_SCAN_TYPES=("-sS SYN Scan" "-sT TCP Connect" "-sU UDP Scan" "-sV Version Detection" "-O OS Detection" "-sn Ping Scan" "--scanflags Custom Flags")
ALL_NSE_CATEGORIES=(auth broadcast brute default discovery dos exploit external fuzzer intrusive malware safe version vuln)
COMMON_NSE_SCRIPTS=( $(find /usr/share/nmap/scripts -type f -name "*.nse" -exec basename {} .nse \; | sort) )

### --- Helpers ---
pause() { read -rp "Press [Enter] to continue..."; }
array_contains() { local val; for val in "${!2}"; do [[ "$val" == "$1" ]] && return 0; done; return 1; }
join_by_comma() { local IFS=','; echo "$*"; }

set_targets() {
  read -rp "Enter target(s) (IP/CIDR/hostnames): " TARGETS
}

scan_type_menu() {
  PS3="Toggle scan type (space to mark, enter to accept): "
  select opt in "${ALL_SCAN_TYPES[@]}" "Done"; do
    [[ "$opt" == "Done" ]] && break
    key=${opt%% *}
    if [[ " ${SCAN_TYPES[*]} " =~ " $opt " ]]; then
      SCAN_TYPES=("${SCAN_TYPES[@]/$opt}")
      echo "Removed $key"
    else
      SCAN_TYPES+=("$opt")
      echo "Added $key"
    fi
  done
  pause
}

ports_menu() {
  echo "Current ports: ${VALUES[ports]}"
  read -rp "Enter ports/range (e.g. 80,443 or 1-65535 or U:53,T:1-100): " p
  [[ -n "$p" ]] && VALUES[ports]="$p"
  pause
}

timing_menu() {
  PS3="Choose timing template: "
  times=("-T0 Paranoid" "-T1 Sneaky" "-T2 Polite" "-T3 Normal" "-T4 Aggressive" "-T5 Insane" "Back")
  select choice in "${times[@]}"; do
    [[ "$choice" == "Back" ]] && break
    [[ -n "$choice" ]] || { echo "Invalid."; continue; }
    VALUES[timing]="${choice%% *}"
    break
  done
  pause
}

host_discovery_menu() {
  PS3="Toggle host discovery flag: "
  opts=("Pn" "PE" "PP" "PM" "PS" "PB" "Back")
  select f in "${opts[@]}"; do
    [[ "$f" == "Back" ]] && break
    FLAGS[$f]=$( [[ ${FLAGS[$f]} == true ]] && echo false || echo true )
    echo "$f toggled to ${FLAGS[$f]}"
    break
  done
  pause
}

toggle_flags() {
  keys=("${!FLAGS[@]}")
  PS3="Toggle flag: "
  select k in "${keys[@]}" "Back"; do
    [[ "$k" == "Back" ]] && break
    FLAGS[$k]=$( [[ ${FLAGS[$k]} == true ]] && echo false || echo true )
    echo "$k toggled to ${FLAGS[$k]}"
    break
  done
  pause
}

nse_menu() {
  while true; do
    clear
    echo "NSE Scripts Menu"
    echo "1) Add category"
    echo "2) Add individual script"
    echo "3) Remove"
    echo "4) Script arguments"
    echo "5) View selected"
    echo "0) Back"
    read -rp "Choice: " c
    case $c in
      1)
        select cat in "${ALL_NSE_CATEGORIES[@]}" "Back"; do
          [[ "$cat" == "Back" ]] && break
          NSE_CATEGORIES+=("$cat")
          break
        done ;;
      2)
        while true; do
          echo "Select a script to add (installed NSE scripts):"
          select scr in "${COMMON_NSE_SCRIPTS[@]}" "Back"; do
            [[ "$scr" == "Back" ]] && break 2
            if [[ -n "$scr" && ! " ${NSE_SCRIPTS[*]} " =~ " $scr " ]]; then
              NSE_SCRIPTS+=("$scr")
              echo "Added: $scr"
            else
              echo "Already selected or invalid."
            fi
            break
          done
        done ;;
      3)
        select item in "${NSE_SCRIPTS[@]}" "${NSE_CATEGORIES[@]}" "Back"; do
          [[ "$item" == "Back" ]] && break
          NSE_SCRIPTS=("${NSE_SCRIPTS[@]/$item}")
          NSE_CATEGORIES=("${NSE_CATEGORIES[@]/$item}")
          break
        done ;;
      4)
        read -rp "Arg (name=value): " pair
        IFS='=' read -r k v <<< "$pair"
        [[ -n "$k" && -n "$v" ]] && NSE_ARGS[$k]="$v"
        ;;
      5)
        echo "Categories: ${NSE_CATEGORIES[*]}"
        echo "Scripts: ${NSE_SCRIPTS[*]}"
        echo "Args:"; for k in "${!NSE_ARGS[@]}"; do echo "  $k=${NSE_ARGS[$k]}"; done
        pause ;;
      0) break ;;
      *) echo "Invalid."; pause ;;
    esac
  done
}

output_menu() {
  PS3="Choose output: "
  opts=("-oN Normal" "-oG Grepable" "-oX XML" "-oA All" "Plain" "Back")
  select o in "${opts[@]}"; do
    [[ "$o" == "Back" ]] && break
    if [[ "$o" == "Plain" ]]; then
      VALUES[output_format]=""
    else
      ofmt=${o%% *}
      read -rp "Filename: " fname
      VALUES[output_format]="$ofmt $fname"
    fi
    break
  done
  pause
}

build_and_run() {
  cmd=(nmap)
  for s in "${SCAN_TYPES[@]}"; do cmd+=("${s%% *}"); done
  [[ -n ${VALUES[ports]} ]] && cmd+=("-p" "${VALUES[ports]}")
  [[ -n ${VALUES[timing]} ]] && cmd+=("${VALUES[timing]}")
  for f in "${!FLAGS[@]}"; do [[ ${FLAGS[$f]} == true ]] && cmd+=("-$f"); done

  # NSE
  local scripts_combined=()
  [[ ${#NSE_CATEGORIES[@]} -gt 0 ]] && scripts_combined+=("${NSE_CATEGORIES[@]}")
  [[ ${#NSE_SCRIPTS[@]} -gt 0 ]] && scripts_combined+=("${NSE_SCRIPTS[@]}")
  if ((${#scripts_combined[@]})); then
    cmd+=("--script=$(join_by_comma ${scripts_combined[@]})")
  fi
  if ((${#NSE_ARGS[@]})); then
    local args=()
    for k in "${!NSE_ARGS[@]}"; do args+=("$k=${NSE_ARGS[$k]}"); done
    cmd+=("--script-args=$(join_by_comma ${args[@]})")
  fi

  [[ -n ${VALUES[output_format]} ]] && cmd+=(${VALUES[output_format]})
  cmd+=("$TARGETS")

  echo -e "\n=== COMMAND ===\n${cmd[*]}\n================"
  read -rp "Run this command? [y/N]: " yn
  [[ $yn =~ ^[Yy]$ ]] && eval "${cmd[*]}"
  pause
}

### --- Menus ---
show_main_menu() {
  clear
  echo "================================"
  echo " Interactive Nmap Menu"
  echo "================================"
  echo "Targets:    ${TARGETS:-<not set>}"
  echo -n "Scan:       "; if ((${#SCAN_TYPES[@]})); then
    for s in "${SCAN_TYPES[@]}"; do printf '%s ' "${s%% *}"; done; echo
  else
    echo "<none>"
  fi
  echo "Ports:      ${VALUES[ports]}"
  echo "Timing:     ${VALUES[timing]}"
  echo -n "Flags:      "; for f in "${!FLAGS[@]}"; do [[ ${FLAGS[$f]} == true ]] && printf -- "-%s " "$f"; done; echo
  echo "NSE cat:    ${#NSE_CATEGORIES[@]}  scripts: ${#NSE_SCRIPTS[@]}"
  echo -n "Output:     "; [[ -n ${VALUES[output_format]} ]] && echo "${VALUES[output_format]}" || echo "<plain>"
  echo "--------------------------------"
  echo "1) Set Targets"
  echo "2) Scan Types"
  echo "3) Ports & Ranges"
  echo "4) Timing"
  echo "5) Host Discovery"
  echo "6) Toggle Flags"
  echo "7) NSE Scripting"
  echo "8) Output Options"
  echo "9) Review & Run"
  echo "0) Exit"
  echo "================================"
}

# Main loop
while true; do
  show_main_menu
  read -rp "Choice: " c
  case $c in
    1) set_targets ;; 2) scan_type_menu ;; 3) ports_menu ;; 4) timing_menu ;;
    5) host_discovery_menu ;; 6) toggle_flags ;; 7) nse_menu ;;
    8) output_menu ;; 9) build_and_run ;; 0) echo "Goodbye!"; exit 0;;
    *) echo "Invalid."; pause;;
  esac
done
