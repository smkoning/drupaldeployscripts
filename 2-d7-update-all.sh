#!/bin/bash
#
# This script will backup all mysql databases of the multisite in separate .sql.tgz files
# At the end a file backup will be created also.
#
# Dependencies for this script are:
# - drush 6.x (https://github.com/drush-ops/drush)
# 
# Drush extensions:
# - Registry Rebuild 7.x (https://www.drupal.org/project/registry_rebuild)
# 
#
#

# Variables (please set before using script)
DRUPAL_ROOT=/path/to/drupalroot


echo
echo -e "\033[2mDrupal Deploy Script v0.1\033[0m"

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

# Goto drupalroot
cd $DRUPAL_ROOT

# loop thru sites directory and perform db backup per vestiging site
for site in `ls sites`
do
        if [ -f sites/$site/settings.php ]
        then
                echo
                echo "=============== $site ==============";

                # Drush commands
                drush_command "Rebuild Drupal registry" "-l $site rr"
                drush_command "Perform Drupal database updates" "-l $site updb -y"

                # Drush 6.x and later already clear cache after updb
                if [[ `drush version --pipe` != 6.* ]]; then
                  drush_command "Clear Drupal caches again because you're not using Drush 6.x" "-l $site cc all"
                fi

                drush_command "Revert all Drupal features" "-l $site fra -y"
                drush_command "Clear Drupal caches" "-l $site cc all"
                drush_command "Retrieving Drupal Feature list" "-l $site fl";

        fi
done

# All done!
echo -e "\n\033[32mFinished without errors!\033[0m\n"
