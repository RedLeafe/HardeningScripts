#!/bin/bash

ORAG='\033[0;33m'
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;36m'
NC='\033[0m'

CHANGEPASSWORD() {
	BIN=$( which chpasswd || which passwd )
	if echo "$BIN" | grep -qi "chpasswd"; then
		CMD="echo \"$1:$2\" | $BIN"
	elif echo "$BIN" | grep -qi "passwd"; then
		CMD="printf \"$2\\n$2\\n\" | $BIN $1" 
	fi
	sh -c "$CMD" >/dev/null 2>&1
}

printf "${BLUE}username,password${NC}\n"

for u in $(cat /etc/passwd | grep -E "/bin/.*sh" | cut -d":" -f1); do 
	pass=$(cat /dev/urandom | tr -dc '[:alpha:][:digit:]' | fold -w ${1:-20} | head -n 1)
	CHANGEPASSWORD $u $pass
	printf "${ORAG}$u,$pass${NC}"
done	

for u in $(cat /etc/passwd | grep -vE "/bin/.*sh" | cut -d":" -f1); do 
	passwd -l $u >/dev/null 2>&1
done