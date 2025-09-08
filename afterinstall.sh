#!/bin/bash
checkers() {
    if [ "$EUID" -ne 0 ]; then
        echo "Запуск от root"
        exit 1
    fi
    #проверка на дистрибутив
    distro=$(head -n 1 /etc/os-release)
    distro=${distro:6:18}
    if [[ "$distro" != 'ALT SP Workstation' ]]; then
        echo "Это не ALT SP(("
        exit 1
    fi

    current_release=$(grep VERSION_ID /etc/os-release)
    current_release=${current_release:11:10}
    if [[ "$current_release" == 10 && $(rpm --eval='%_priority_distbranch') != "c10f2" ]]; then
        return 1
    fi
    if rpm -q firmware-linux-20221202-alt1.noarch; then

        return 2
    fi
}

systemupdate() {
    apt-get update
    if [[ $? != 0 ]]; then
        echo "Произошла ошибка при обновлении, нет интернета?"
        exit 1
    fi
    apt-get dist-upgrade -y
    if [[ $? != 0 ]]; then
        echo "Произошла ошибка при обновлении"
        exit 1
    fi
    update-kernel -y
    if [[ $? != 0 ]]; then
        echo "Произошла ошибка при update-kernel, выдали root права через su- а не su - ?"
        exit 1
    fi
}

firstLaunch() {
    #Убрать noexec из fstab
    fstab=$(grep '/home' /etc/fstab)
    if [[ $? == 0 ]]; then
        newfstab=$(printf '%s\n' "${fstab//noexec,/}")
        sed -i "s~${fstab}~${newfstab}~g" /etc/fstab
    fi
    apt-repo rm all
    sed -i -e 's/#rpm\ \[cert8\]\ http/rpm\ \[cert8\]\ http/g' /etc/apt/sources.list.d/altsp.list
    systemupdate
    if ! rpm -q nano; then
        apt-get install nano -y
    fi
    sed -i -e 's/c10f/c10f2/g' /etc/apt/sources.list.d/altsp.list
    apt-get clean
    echo '%_priority_distbranch c10f2' >/etc/rpm/macros.d/priority_distbranch
    integalert fix
    systemctl set-default multi-user.target
    echo "Первичные обновления установлены, перезагрузите пк, дальше Вы будете работать через терминал, после перезагрузки запустите скрипт еще раз"
}

secondLauch() {
    if [[ $(systemctl get-default) != multi-user.target ]]; then
        echo "Последующее обновленее только в режиме multi-user.target"
        exit 1
    fi
    apt-get clean
    systemupdate
    apt-get install kde5 -y
    systemctl set-default graphical.target
    mkdir /var/log/integalert
    touch /var/log/integalert/lastlog
    integalert fix
    echo "Обновление завершено, перезагрузите компьютер"
}

main() {
    checkers
    case $? in
    1) firstLaunch ;;
    2) secondLauch ;;
    *) echo "Делать нечего" ;;
    esac

}

main
