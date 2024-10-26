#!/bin/bash

ORAG='\033[0;33m'
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;36m'
NC='\033[0m'

# backup /etc/passwd
mkdir /root/.cache 2>/dev/null
cp /etc/passwd /root/.cache/users

# kernel modules check
mkdir /root/.cache/kernel 2>/dev/null
lsmod > /root/.cache/kernel/base_kernel_modules

# check our ports
( netstat -tlpn 2>/dev/null || ss -plnt 2>/dev/null ) > /root/.cache/listen
( netstat -tpwn 2>/dev/null || ss -pnt | grep ESTAB 2>/dev/null ) > /root/.cache/estab

# pam
mkdir /etc/pam.d/pam/ 2>/dev/null
cp -R /etc/pam.d/ /root/.cache/pam

# profiles
for f in '.profile' '.*shrc' '.*sh_login'; do
    find /home /root -name "$f" -exec rm {} \;
done

# php
# Thanks UCI

sys=$(command -v service || command -v systemctl || command -v rc-service)

for file in $(find / -name 'php.ini' 2>/dev/null); do
	mkdir /root/.cache/php
	cp $file /root/.cache/php/$file

	echo "disable_functions = 1e, exec, system, shell_exec, passthru, popen, curl_exec, curl_multi_exec, parse_file_file, show_source, proc_open, pcntl_exec/" >> $file
	echo "track_errors = off" >> $file
	echo "html_errors = off" >> $file
	echo "max_execution_time = 3" >> $file
	echo "display_errors = off" >> $file
	echo "short_open_tag = off" >> $file
	echo "session.cookie_httponly = 1" >> $file
	echo "session.use_only_cookies = 1" >> $file
	echo "session.cookie_secure = 1" >> $file
	echo "expose_php = off" >> $file
	echo "magic_quotes_gpc = off " >> $file
	echo "allow_url_fopen = off" >> $file
	echo "allow_url_include = off" >> $file
	echo "register_globals = off" >> $file
	echo "file_uploads = off" >> $file

	echo $file changed

done;

if [ -d /etc/nginx ]; then
	$sys nginx restart || $sys restart nginx
	echo nginx restarted
fi

if [ -d /etc/apache2 ]; then
	$sys apache2 restart || $sys restart apache2
	echo apache2 restarted
fi

if [ -d /etc/httpd ]; then
	$sys httpd restart || $sys restart httpd
	echo httpd restarted
fi

if [ -d /etc/lighttpd ]; then
	$sys lighttpd restart || $sys restart lighttpd
	echo lighttpd restarted
fi

file=$(find /etc -maxdepth 2 -type f -name 'php-fpm*' -print -quit)

if [ -d /etc/php/*/fpm ] || [ -n "$file" ]; then
        $sys *php* restart || $sys restart *php*
        echo php-fpm restarted
fi

printf "${RED}Completed backups and basic hardening${NC}\n"
