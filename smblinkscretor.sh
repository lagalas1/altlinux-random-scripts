#!/bin/bash
IFS=$'\n'
GROUPNAME='GROUPNAME'
desktop_directory() {
    if [[ -d "$HOME"/Desktop ]]; then
        DESKTOPDIRECTORY="$HOME"/Desktop
    elif [[ -d "$HOME"/Рабочий\ стол ]]; then
        DESKTOPDIRECTORY="$HOME"/Рабочий\ стол
    else
        echo No desktop directory, abort
        exit 1
    fi
}

checkers() {
    if [[ "$GROUPNAME" == 'GROUPNAME']]; then
    echo "Замените переменную GROUPNAME в файле"
    exit 1
    fi
    if ! groups "$USER" | grep "$GROUPNAME" &>/dev/null; then
        echo "$USER" not in "$GROUPNAME" group
        exit 1
    fi
    FILES=$(find "$DESKTOPDIRECTORY" -name "*.desktop") &>/dev/null
    bZDETECTED=false
    bSCANDETECTED=false

    if [[ -n "$FILES" ]]; then
        for FILE in $FILES; do
            if grep 'URL\[$e\]=smb://ЗАМЕНИТЬIP/t' "$FILE" &>/dev/null; then
                bZDETECTED=true
            elif grep 'URL\[$e\]=smb://ЗАМЕНИТЬIP/SCAN' "$FILE" &>/dev/null; then
                bSCANDETECTED=true
            fi
        done
    fi

}

main() {
    desktop_directory
    checkers
    if [[ "$bZDETECTED" == "true" ]]; then
        echo "Z already created"
    else
        touch "$DESKTOPDIRECTORY"/Z.desktop
        echo '[Desktop Entry]
Icon=inode-directory
Name[ru_RU]=Z
Name=Z
Type=Link
URL[$e]=smb://ЗАМЕНИТЬIP/t' >"$DESKTOPDIRECTORY"/Z.desktop
    fi

    if [[ "$bSCANDETECTED" == "true" ]]; then
        echo "Scan already created"
    else
        touch "$DESKTOPDIRECTORY"/"scan linux.desktop"
        echo '[Desktop Entry]
Icon=inode-directory
Name[ru_RU]=scan linux
Name=scan linux
Type=Link
URL[$e]=smb://ЗАМЕНИТЬIP/SCAN' >"$DESKTOPDIRECTORY"/"scan linux.desktop"
    fi
}

main
