#!/bin/bash
SSHUSER='TYPEUSER'
if [ "$V" == 'TYPEUSER' ]
  then echo "Замените SSHUSER в конфиг файле"
  exit
fi
if [ "$EUID" == 0 ]
  then echo "Запуск не от root"
  exit
fi
if ! [[ $(ls ForRemote/supportitk.sh) ]]
then
echo 'Пожалуйста, расположите папку Packages с его содержимым в одной папке со скриптом MyOfficeInstall'
exit
fi
if ! [[ $(rpm -q sshpass) ]]
then
echo 'Пожалуйста, установите sshpass'
exit
fi
chmod +x ForRemote/supportitk.sh
read -s -p "Пароль админа: " PASSW
echo -e "\nПроверка"
sshpass -p "$PASSW" ssh -o "StrictHostKeyChecking=accept-new" -q "$SSHUSER"@127.0.0.1 "exit"
if [[ $? != 0 ]]
then
echo "Неверный пароль"
exit
fi
while true; do
    read -r -p "Введите имя ПК\ip (несколько через пробел) или оставьте поле пустым чтобы выйти: " PCS
    if [ "$PCS" == "" ]
		then
		exit 0
		else
		for PC in $PCS
do
echo "Попытка передачи файлов на "$PC""
        if $(sshpass -p "$PASSW" scp -o "StrictHostKeyChecking=accept-new" -r ForRemote/* "$SSHUSER"@"$PC":/home/OGVKK.RU/d_a_iashchenko/)
then
echo -e "\033[32m Файлы переданы \033[0m"
   sshpass -p "$PASSW" ssh -o "StrictHostKeyChecking=accept-new" "$SSHUSER"@"$PC" "echo '$PASSW'|sudo -S /bin/bash supportitk.sh"
else
  echo -e "\033[31m Устройство "$PC" недоступно \033[0m"
fi
done
  fi
done
