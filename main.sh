#!/bin/bash

while getopts "hvi:" flag; do
  case $flag in
    h)
      # Display script help information
      echo "Usage: main.sh [-i LocalNetwork]"
      exit 0
      ;;
    i)
      # Handle the -f flag with an argument
      LOCALNETWORK=$OPTARG
      ;;
    \?)
      # Handle invalid options
      echo "Invalid option: -$OPTARG" >&2
      exit 1
      ;;
    :)
      # Handle missing option argument
      echo "Option -$OPTARG requires an argument." >&2
      exit 1
      ;;
  esac
done

if [ -z "$LOCALNETWORK" ]; then
	echo "Usage: main.sh [-i LocalNetwork]"
	exit 1
fi

ipt=$(command -v iptables || command -v /sbin/iptables || command -v /usr/sbin/iptables)
$ipt -P INPUT ACCEPT; $ipt -P OUTPUT ACCEPT ; $ipt -P FORWARD ACCEPT ; $ipt -F; $ipt -X


printf "############Stolen Scripts############\n\n"

# enable scripts
find . -type f -name "*.sh" -exec chmod +x {} \;

./start/name.sh

printf "############Running Updates############\n\n"
./start/updates.sh &

printf "############Running Base Set Up############\n\n"
./start/backups.sh &
./start/ipt.sh "$LOCALNETWORK"

wait

printf "############Running Hardening Scripts############\n\n"
./Hardening/container.sh &
./Hardening/cron.sh &
./Hardening/pam.sh

wait

./Hardening/password.sh

printf "############Running Enumeration Scripts############\n\n"
./Enum/db.sh
./Enum/inventory.sh
./Enum/kube.sh
./Enum/web.sh

printf "############Completed Initial Configuration############\n\n"

$ipt -P FORWARD ACCEPT; $ipt -P OUTPUT DROP;