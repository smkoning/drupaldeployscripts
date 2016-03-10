#!/bin/bash

# Settings has to be changed per environment:
# ACTBRANCH is the branch which is different per environment:
# * test: develop
# * acceptance: release/1.*
# * production: master
#
# REPODIR is the full path to the drupal root (where index.php is...)
#

ACTBRANCH=develop
REPODIR=/path/to/drupalroot


echo -e "\033[2mDrupal Deploy Script v1.0\033[0m"

# Function to display current status in dimmed font
status_message() {
  echo
  echo -e "\033[2m$1...\033[0m"
}

# Function to show error message and exit
exit_error() {
  echo
  echo -e "\033[31m$1\033[0m"
  if [ ! -z "$2" ]; then
    echo -e "$2"
  fi
  echo
  exit 1
}

# Function to perform drush command and exit on failure
drush_command () {
  status_message "$1"
  drush $2
  if [[ $? -ne 0 ]]; then
    exit_error "Drush $2 failed, aborting!"
  fi
}

# Check if repo dir exists
if [ ! -d "$REPODIR" ]; then
  exit_error "\"$REPODIR\" not found!" "Please change \033[1mREPODIR\033[0m and refire."
fi

# Show settings
echo
echo -e "REPODIR:     \033[1m$REPODIR\033[0m"
echo

# Confirm branch setting
read -s -n1 -p "Are these settings correct? [y/N]: " CONFIRMSETTINGS
if [[ ! $CONFIRMSETTINGS =~ ^(Y|y) ]]; then
  echo "n"
  echo "Please change the settings and refire."
  echo
  exit
fi

echo "y"

# Go to repo dir
status_message "Open repo dir"
if ! cd $REPODIR &> /dev/null --; then
  exit_error "Unable to open \"$REPODIR\"!" "Make sure this account has acces to the folder and refire."
fi

# Checkout active branch just to be sure
status_message "Checkout $ACTBRANCH"
if ! git checkout $ACTBRANCH --; then
  exit_error "Checkout of \"$ACTBRANCH\" failed!" "Make sure this is the correct branch and refire."
fi

# Check for uncomitted changes
if ! git diff-index --quiet HEAD --; then
  exit_error "Working directory is not clean!" "Please commit or discard any changes and refire."
fi

# Pull all changes
status_message "Perform git pull"
if ! git pull --; then
  exit_error "Git pull failed, aborting!"
fi

# All done!
echo -e "\n\033[32mFinished without errors!\033[0m\n"
