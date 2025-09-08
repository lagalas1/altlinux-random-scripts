#!/bin/bash

readonly HEIGHT=20
readonly WIDTH=78

if ! command -v whiptail &> /dev/null ; then
     echo "Пожалуйста установите whiptail"
     exit 1
fi

whiptail --title  "Мастер установки крипопро" --msgbox  "Дороу." $HEIGHT $WIDTH
if (whiptail --title  "Test Yes/No Box" --yesno  "Choose between Yes and No." $HEIGHT $WIDTH)
then
     echo "You chose Yes. Exit status was $?."
else
     echo "You chose No. Exit status was $?."
fi

if (whiptail --title  "Test Yes/No Box" --yes-button  "Skittles" --no-button  "M&M's"  --yesno  "Which do you like better?" 10 60)  
then
     echo "You chose Skittles Exit status was $?."
else
     echo "You chose M&M's. Exit status was $?."
fi

PET=$(whiptail --title  "Test Free-form Input Box" --inputbox  "What is your pet's name?" 10 60 Wigglebutt 3>&1 1>&2 2>&3)
exitstatus=$?
if [ $exitstatus = 0 ];  then
     echo "Your pet name is: $PET"
else
     echo "You chose Cancel."
fi

PASSWORD=$(whiptail --title  "Test Password Box" --passwordbox  "Enter your password and choose Ok to continue." 10 60 3>&1 1>&2 2>&3)
exitstatus=$?
if [ $exitstatus = 0 ];  then
     echo "Your password is:" "$PASSWORD"
else
     echo "You chose Cancel."
fi

OPTION=$(whiptail --title  "Test Menu Dialog" --menu  "Choose your option" 15 60 4 \
"1" "Grilled Spicy Sausage" \
"2" "Grilled Halloumi Cheese" \
"3" "Charcoaled Chicken Wings" \
"4" "Fried Aubergine"  3>&1 1>&2 2>&3)
 
exitstatus=$?
if [ $exitstatus = 0 ];  then
     echo "Your chosen option:" "$OPTION"
     else
     echo "You chose Cancel."
fi

DISTROS=$(whiptail --title  "Test Checklist Dialog" --radiolist \
"What is the Linux distro of your choice?" 15 60 4 \
"debian" "Venerable Debian" ON \
"ubuntu" "Popular Ubuntu" OFF \
"fedora" "Stable CentOS" OFF \
"centOS" "Rising Star Mint" OFF 3>&1 1>&2 2>&3)
 
exitstatus=$?
if [ $exitstatus = 0 ];  then
     echo "The chosen distro is:" "$DISTROS"
else
     echo "You chose Cancel."
fi

DISTROS=$(whiptail --title  "Test Checklist Dialog" --checklist \
"Choose preferred Linux distros" 15 60 4 \
"debian" "Venerable Debian" ON \
"ubuntu" "Popular Ubuntu" OFF \
"fedora" "Stable CentOS" ON \
"centOS" "Rising Star Mint" OFF 3>&1 1>&2 2>&3)
 
exitstatus=$?
if [ $exitstatus = 0 ];  then
     echo "Your favorite distros are:" "$DISTROS"
else
     echo "You chose Cancel."
fi

{
     for ((i = 0 ; i <= 100 ; i+=20));  do
         sleep 1
         echo $i
     done
} | whiptail --gauge  "Please wait while installing" 6 60 0