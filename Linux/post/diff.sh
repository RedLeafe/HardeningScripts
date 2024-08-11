#!/bin/sh
# @d_tranman/Nigel Gerald/Nigerald

printf "#############Netstat############\n\n"

( netstat -tlpn || ss -plnt ) > /tmp/listen
( netstat -tpwn || ss -pnt | grep ESTAB ) > /tmp/estab

diff /root/.cache/listen /tmp/listen
diff /root/.cache/estab /tmp/estab

rm /tmp/listen
rm /tmp/estab

printf "#############Users############\n\n"

diff /etc/passwd /root/.cache/users

printf "#############Kernel Modules############\n\n"

lsmod > /tmp/check_kernel_modules

diff /tmp/check_kernel_modules /root/.cache/kernel/base_kernel_modules

rm /tmp/check_kernel_modules