#!/bin/bash

ORAG='\033[0;33m'
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;36m'
NC='\033[0m'

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
save=$(command -v iptables-save || command -v /sbin/iptables-save || command -v /usr/sbin/iptables-save)


printf "${GREEN}############Stolen Scripts############${NC}\n\n"

# enable scripts
find . -type f -name "*.sh" -exec chmod +x {} \;

./start/name.sh

printf "${GREEN}\n############Running Updates############${NC}\n\n"
./start/updates.sh &

printf "${GREEN}############Running Base Set Up############${NC}\n\n"
./start/backups.sh &
./start/ipt.sh "$LOCALNETWORK"

wait

printf "${GREEN}\n############Running Hardening Scripts############${NC}\n\n"
./Hardening/container.sh &
./Hardening/cron.sh &
./Hardening/pam.sh

wait

printf "\n${GREEN}\n############Running Enumeration Scripts############${NC}\n\n"
./Enum/db.sh
./Enum/inventory.sh
./Enum/web.sh

printf "\n\n${GREEN}############Completed Initial Configuration############${NC}\n\n"

DEBIAN_FRONTEND=noninteractive apt-get -y install iptables-persistent

$ipt -P FORWARD ACCEPT; $ipt -P OUTPUT DROP;

$save > /etc/iptables/rules.v4

systemctl start reboot.target