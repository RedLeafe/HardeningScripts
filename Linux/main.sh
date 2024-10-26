#!/bin/bash

ORAG='\033[0;33m'
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;36m'
NC='\033[0m'

if [[ $UID -ne 0 ]]; then
   printf "${RED}This script must be run as root. Please switch to the root user.${NC}" 
   exit 1
fi

while getopts "hvi:" flag; do
  case $flag in
    h)
      echo "Usage: main.sh [-i LocalNetwork]"
      exit 0
      ;;
    i)
      LOCALNETWORK=$OPTARG
      ;;
    #u)
    #  USER=$OPTARG
    #  ;;
    \?)
      echo "Invalid option: -$OPTARG" >&2
      exit 1
      ;;
    :)
      echo "Option -$OPTARG requires an argument." >&2
      exit 1
      ;;
  esac
done

if [ -z "$LOCALNETWORK" ]; then
	echo "Usage: main.sh [-i LocalNetwork]"
	exit 1
fi

#if [ -z "$USER" ]; then
#	echo "Usage: main.sh [-i LocalNetwork] [-u UserIP]"
#	exit 1
#fi

ipt=$(command -v iptables || command -v /sbin/iptables || command -v /usr/sbin/iptables)
$ipt -P INPUT ACCEPT; $ipt -P OUTPUT ACCEPT ; $ipt -P FORWARD ACCEPT ; $ipt -F; $ipt -X

printf "${GREEN}############Stolen Scripts############${NC}\n\n"

# enable scripts
find . -type f -name "*.sh" -exec chmod +x {} \;

./start/name.sh

printf "${GREEN}\n############Running Updates############${NC}\n\n"
./start/updates.sh &
./Hardening/pam.sh

wait

printf "${GREEN}############Running Base Set Up############${NC}\n\n"
./start/backups.sh &
./start/ipt.sh "$LOCALNETWORK" #"$USER"

wait

printf "${GREEN}\n############Running Hardening Scripts############${NC}\n\n"
./Hardening/container.sh &
./Hardening/cron.sh

wait

printf "\n${GREEN}\n############Running Enumeration Scripts############${NC}\n\n"
./Enum/db.sh > /root/.cache/db
echo "db enumeration > /root/.cache/db"

./Enum/inventory.sh > /root/.cache/inventory
echo "inventory > /root/.cache/inventory"

./Enum/web.sh > /root/.cache/web
echo "web enumeration /root/.cache/web"

printf "\n\n${GREEN}############Completed Initial Configuration############${NC}\n\n"