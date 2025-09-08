#!/bin/bash
NEWUSER='TYPEUSER'
NEWUSERPASS='TYPEPASS'
checkers() {
    if [[ NEWUSER == 'TYPEUSER' ]]; then
        echo "Замените NEWUSER в конфиге"
        exit 1
    fi
    if [[ NEWUSERPASS == 'TYPEPASS' ]]; then
        echo "Замените NEWUSER в конфиге"
        exit 1
    fi
    if [ "$EUID" -ne 0 ]; then
        echo "Запуск от root"
        exit 1
    fi
}

main() {

    checkers
    useradd -M -p "$NEWUSERPASS" "$NEWUSER" &&
        echo -e "Пользователь $NEWUSER создан"

    echo 'polkit.addRule(function(action, subject) {
if (action.id == "org.freedesktop.udisks2.filesystem-mount") {
    return polkit.Result.AUTH_ADMIN;
}
});
polkit.addAdminRule(function(action, subject) {
if (action.id == "org.freedesktop.udisks2.filesystem-mount" || action.id == "ru.securitycode.pkexec.ctsg"  || action.id == "ru.securitycode.pkexec.ctsdiagnosticsg" || action.id == "ru.securitycode.pkexec.ctsicg") {
    return ["unix-user:supportitk", "unix-group:wheel"];
}
});
' >/etc/polkit-1/rules.d/00-admin.rules &&
        echo "Добавлены правила в /etc/polkit-1/rules.d/00-admin.rules"
}

main
