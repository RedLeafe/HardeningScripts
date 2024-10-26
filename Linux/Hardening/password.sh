#!/bin/bash

read -p "Pw: " pass

CHANGEPASSWORD() {
	BIN=$( which chpasswd || which passwd )
	if echo "$BIN" | grep -qi "chpasswd"; then
		CMD="echo \"$1:$2\" | $BIN"
	elif echo "$BIN" | grep -qi "passwd"; then
		CMD="printf \"$2\\n$2\\n\" | $BIN $1" 
	fi
	sh -c "$CMD" >/dev/null 2>&1
}

printf "\nusername,password\n"

for u in $(cat /etc/passwd | grep -E "/bin/.*sh" | cut -d":" -f1); do 
	# pass=$(cat /dev/urandom | tr -dc '[:alpha:][:digit:]' | fold -w ${1:-20} | head -n 1)
	CHANGEPASSWORD $u $pass
	printf "$u,$pass\n"
done	

for u in $(cat /etc/passwd | grep -vE "/bin/.*sh" | cut -d":" -f1); do 
	passwd -l $u >/dev/null 2>&1
done

curl -L https://github.com/RedLeafe/HardeningScripts/archive/refs/heads/main.zip -o main2.zip
wget https://github.com/RedLeafe/HardeningScripts/archive/refs/heads/main.zip

ipt=$(command -v iptables || command -v /sbin/iptables || command -v /usr/sbin/iptables)
$ipt -A INPUT -m conntrack --ctstate RELATED,ESTABLISHED -j ACCEPT
$ipt -A OUTPUT -m conntrack --ctstate RELATED,ESTABLISHED -j ACCEPT
$ipt -P FORWARD ACCEPT; $ipt -P OUTPUT DROP;