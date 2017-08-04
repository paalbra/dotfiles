#!/bin/bash

REPO_DIR=$(pwd -P)

FILES=$(find $REPO_DIR/files -maxdepth 1 -type f -name ".*" | sed -n "s|^$REPO_DIR/files/||p")
BACKUP_DIR=$REPO_DIR/backup_$(date +%Y%m%d-%H%M%S)
mkdir -p $BACKUP_DIR

echo "Installing dotfiles (old files are moved to $BACKUP_DIR)."

# Copy all the files
for FILE in $FILES
do
	if [ -f ~/$FILE ]; then
		mv -v -i ~/$FILE $BACKUP_DIR
	fi
	cp -v -i files/$FILE ~/
done

echo "Configuring variables."

# Replace variables
echo "-- What name do you want to use for git?"
read git_user_name

echo "-- What email do you want to use for git?"
read git_user_email

sed -i "s/{git_user_name}/$git_user_name/g" ~/.gitconfig
sed -i "s/{git_user_email}/$git_user_email/g" ~/.gitconfig

echo "Configuring variables done."

echo "Done!"
