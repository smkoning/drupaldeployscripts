#!/bin/bash
#
# This script will backup all mysql databases of the multisite in separate .sql.tgz files
# At the end a file backup will be created also.
#
# Dependencies for this script are:
# - drush 6.x (https://github.com/drush-ops/drush)
#
# Backups are written to variable:
# - BACKUP_DESTINATION
#
#

# Variables (please set before using script)
BACKUP_DESTINATION=/path/to/destination
DRUPAL_ROOT=/path/to/drupalroot
DATE=$(date +%Y%m%d-%H%M)

echo
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
  break 1
}

# Function to perform drush command and exit on failure
drush_command () {
  status_message "$1"
  drush $2
  if [[ $? -ne 0 ]]; then
    echo "Drush $2 failed, aborting!"
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
                echo -e "=============== $site ==============";
                drush_command "Create Mysql Backup for $site" "-l $site sql-dump --result-file=$BACKUP_DESTINATION/$DATE-$site --gzip" ;
        fi
done

#Backup files directory
#echo
#echo -e "Backup drupal files"
#tar cvzf $BACKUP_DESTINATION/$DATE-drupal.tar.gz ./*

# All done!
echo -e "\n\033[32mFinished without errors!\033[0m\n"
