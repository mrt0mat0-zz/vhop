#!/bin/bash
clear
echo "VH Hopper 0.01"
HOST=$1
OPTIONS=`grep 'option' .vhop-config | sed s/option/""/`
AVAILABLE=`grep 'available' .vhop-config | sed s/available/""/`
for option in $OPTIONS
do
  name=$(echo $option | cut -f1 -d:)
  location=$(echo $option | cut -f2 -d:)
  if [ "$HOST" == "$name" ]; then
      file_name=$name
      file_location=$location
  fi
done
echo $AVAILABLE
if [[ -z "$AVAILABLE" ]]; then
  echo "No Available IP Addresses. Delete One"
  echo "(1) 201" 
  echo "(2) 202"
  echo "(3) 203"
  read choice
  files=`ls /etc/apache2/sites-enabled/`
  for file in $files
  do
   if [[ "$file" == "$HOST"  ||  "$file" == $HOST"-ssl" ]]; then
     sudo a2dissite ${file} >/dev/null
     sudo rm /sites/${file} >/dev/null
   fi
   
   check=0
   if grep -q "10.1.1.20$choice" "/etc/apache2/sites-enabled/$file" &> /dev/null; then
     remove=$file
     check=1
     break
   fi
  done
  if [ "$check" == "1" ]; then
   sudo a2dissite ${file}* > /dev/null
   sudo rm /sites/${file}* 
  fi
  AVAILABLE="20$choice"
fi
for address in $AVAILABLE
do
 file_address=$address
 break
done
sed -e "s/{LOCATION}/$file_location/g" -e "s/{NAME}/$file_name/g" -e "s/{IP_ADDRESS}/$file_address/g" /sites/default1 > "/sites/$file_name"
sed -e "s/{LOCATION}/$file_location/g" -e "s/{NAME}/$file_name/g" -e "s/{IP_ADDRESS}/$file_address/g" /sites/default1-ssl > "/sites/${file_name}-ssl"
sudo a2ensite ${file_name} > /dev/null
sudo a2ensite ${file_name}-ssl > /dev/null 
sudo service apache2 reload  &>/dev/null
sed -i "/available.*${file_address}/d" ~/.vhop-config
echo "Finished"
