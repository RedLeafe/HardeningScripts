#!/bin/bash

printf ############Stolen Scripts############\n\n

printf ############Running Updates############\n\n
./start/updates.sh

printf ############Running Base Set Up############\n\n
./start/backups.sh &&
./start/ipt.sh &&

wait

printf ############Running Hardening Scripts############\n\n
./Hardening/container.sh &&
./Hardening/cron.sh &&
./Hardening/pam.sh &&
./Hardening/password.sh &&

wait

printf ############Running Enumeration Scripts############\n\n
./Enum/name.sh &&
./Enum/db.sh &&
./Enum/inventory.sh &&
./Enum/kube.sh &&
./Enum/web.sh &&

wait

printf ############Completed Initial Configuration############\n\n