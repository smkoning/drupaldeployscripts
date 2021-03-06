#!/bin/bash
#
#
# Dependencies for this script are:
# - drush 8.x (https://github.com/drush-ops/drush)
# - composer
# 

# Variables (please set before using script)
DRUPAL_ROOT=/path/to/drupalroot


echo
echo -e "\033[2mDrupal Deploy Script v1.0.0\033[0m"

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
  break 1
}

# Function to perform drush command and exit on failure
drush_command () {
  status_message "$1"
  drush $2
  if [[ $? -ne 0 ]]; then
    echo "drush $2 failed, aborting!"
  fi
}

# Function to perform composer command and exit on failure
composer_command () {
  status_message "$1"
  composer $2
  if [[ $? -ne 0 ]]; then
  echo "composer $2 failed, aborting!"
  fi
}

# Goto drupalroot
cd $DRUPAL_ROOT

# Composer commands
composer_command "Update Drupal Core first" "-l $site update drupal/core --with-dependencies"
                
# Drush commands
drush_command "Perform Drupal database updates" "-l $site updb -y"
drush_command "Clear Drupal caches" "-l $site cr"

# All done!
echo -e "\n\033[32mFinished without errors!\033[0m\n"
