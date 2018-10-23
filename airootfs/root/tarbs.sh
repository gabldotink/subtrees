  echo -e "You must copy the TARBS scripts to your new Arch installation (located at /mnt),"
  while : ;do
    if [ "$answer" = "g" ];then
      echo -e "You didn't give a valid option, try again."
    else
      read -p "  Would you like to do it now? [y/n] " -t 10 answer
      echo -e "\e[0m"
      if [ "$answer" = "y" ];then
        cp -r /root/TARBS/ /mnt/root/
        echo -e "The TARBS scripts are now located in /root"
        break
        fi
      if [ "$answer" = "n" ];then
        break
      fi
      let answer=g
    fi
  done