#!/bin/bash

CHANGEPASSWORD() {
	BIN=$( which chpasswd || which passwd )
	if echo "$BIN" | grep -qi "chpasswd"; then
		CMD="echo \"$1:$2\" | $BIN"
	elif echo "$BIN" | grep -qi "passwd"; then
		CMD="printf \"$2\\n$2\\n\" | $BIN $1"
	fi
	sh -c "$CMD"
}

echo "username,password"

for u in $(cat /etc/passwd | grep -E "/bin/.*sh" | cut -d":" -f1); do 
	pass=$(cat /dev/urandom | tr -dc '[:alpha:][:digit:]' | fold -w ${1:-20} | head -n 1)
	CHANGEPASSWORD $u $pass
	echo "$u,$pass"
done	

for u in $(cat /etc/passwd | grep -vE "/bin/.*sh" | cut -d":" -f1); 
do passwd -l $u; done