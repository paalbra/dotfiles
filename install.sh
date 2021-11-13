#!/bin/bash

declare -A CONFIG
CONFIGFILE="config.sh"

function getvar() {
    if [ ! -z "${CONFIG[$1]}" ]; then
        echo "${CONFIG[$1]}"
    else
        echo "${2-Type in $1}:" >&2
        read CONFIG[$1]
        echo "${CONFIG[$1]}"
    fi
}

function dumpvars() {
    echo -n > "$1"
    for key in "${!CONFIG[@]}"; do
        echo "CONFIG[$key]='${CONFIG[$key]}'" >> "$1"
    done
}

if [ -f "$CONFIGFILE" ]; then
    source "$CONFIGFILE"
fi

REPO_DIR=$(pwd -P)

pushd ./files > /dev/null
readarray -d '' FILES < <(find . -maxdepth 1 -type f -name ".*" -print0)
popd > /dev/null
BACKUP_DIR="$REPO_DIR/backup_$(date +%Y%m%d-%H%M%S)"
mkdir -p "$BACKUP_DIR"

echo "Installing dotfiles (old files are moved to $BACKUP_DIR)."

# Copy all the files
for FILE in "${FILES[@]}"; do
    SRC=$(realpath "files/$FILE")
    DST=$(realpath "$HOME/$FILE")
    if ! cmp --quiet "$SRC" "$DST"; then
        if [ -f "$DST" ]; then
            mv -v -i "$DST" "$BACKUP_DIR"
        fi
        cp -v -i "$SRC" "$DST"
    fi
done

echo "Configuring variables."

getvar git_user_name "What name do you want to use for git?" > /dev/null
getvar git_user_email "What email do you want to use for git?" > /dev/null

sed -i "s/{git_user_name}/${CONFIG[git_user_name]}/g" ~/.gitconfig
sed -i "s/{git_user_email}/${CONFIG[git_user_email]}/g" ~/.gitconfig

echo "Configuring variables done."

dumpvars "$CONFIGFILE"

echo "Done!"
