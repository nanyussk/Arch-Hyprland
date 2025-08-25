#!/bin/bash
# 💫 https://github.com/JaKooLit 💫 #
# Power Profiles Stuff #

power=(
  power-profiles-daemon
)

## WARNING: DO NOT EDIT BEYOND THIS LINE IF YOU DON'T KNOW WHAT YOU ARE DOING! ##
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Change the working directory to the parent directory of the script
PARENT_DIR="$SCRIPT_DIR/.."
cd "$PARENT_DIR" || { echo "${ERROR} Failed to change directory to $PARENT_DIR"; exit 1; }

# Source the global functions script
if ! source "$(dirname "$(readlink -f "$0")")/Global_functions.sh"; then
  echo "Failed to source Global_functions.sh"
  exit 1
fi

# Set the name of the log file to include the current date and time
LOG="Install-Logs/install-$(date +%d-%H%M%S)_power.log"

# Install Power Profiles packages
printf "${NOTE} Installing ${SKY_BLUE}Power Profiles${RESET} Packages...\n"
for PWR in "${power[@]}"; do
  install_package "$PWR" "$LOG"
done

# Enable Power Profiles daemon
printf " Activating ${YELLOW}Power Profiles${RESET} Services...\n"
sudo systemctl enable --now power-profiles-daemon.service 2>&1 | tee -a "$LOG"

printf "\n%.0s" {1..2}
