#!/bin/sh
# @d_tranman/Nigel Gerald/Nigerald

IS_RHEL=false
IS_DEBIAN=false
IS_ALPINE=false
IS_SLACK=false

ORAG='\033[0;33m'
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;36m'
NC='\033[0m'

if [ -z "$DEBUG" ]; then
	DPRINT() {
    	"$@" 2>/dev/null
	}
else
	DPRINT() {
    	"$@"
	}
fi

RHEL(){
  IS_RHEL=true
}

DEBIAN(){
  IS_DEBIAN=true
}

UBUNTU(){
  DEBIAN
}

ALPINE(){
  IS_ALPINE=true
}

SLACK(){
  IS_SLACK=true
}

if command -v yum >/dev/null ; then
	RHEL
elif command -v apt-get >/dev/null ; then
	if $(cat /etc/os-release | grep -qi Ubuntu); then
    	UBUNTU
	else
    	DEBIAN
	fi
elif command -v apk >/dev/null ; then
	ALPINE
elif command -v slapt-get >/dev/null || (cat /etc/os-release | grep -qi slackware ) ; then
	SLACK
fi

printf "${GREEN}#############SERVICE INFORMATION############${NC}"
if [ $IS_ALPINE = true ]; then
	SERVICES=$( rc-status -s | grep started | awk '{print $1}' )
elif [ $IS_SLACK = true ]; then
	SERVICES=$( ls -la /etc/rc.d | grep rwx | awk '{print $9}' )
else
	SERVICES=$( DPRINT systemctl --type=service | grep active | awk '{print $1}' || service --status-all | grep -E '(+|is running)' )
fi
APACHE2=false
NGINX=false
checkService()
{
	serviceList=$1
	serviceToCheckExists=$2
	serviceAlias=$3           	 

	if [ -n "$serviceAlias" ]; then
    	printf "\n\n${BLUE}[+] $serviceToCheckExists is on this machine${NC}\n\n"
    	if echo "$serviceList" | grep -qi "$serviceAlias\|$serviceToCheckExists" ; then
        	if [ "$( DPRINT netstat -tulpn | grep -i $serviceAlias )" ] ; then
           	 
            	printf "Active on port(s) ${YELLOW}$(netstat -tulpn | grep -i "$serviceAlias\|$serviceToCheckExists"| awk 'BEGIN {ORS=" and "} {print $1, $4}' | sed 's/\(.*\)and /\1\n\n/')${NC}\n\n"
       	 
        	elif [ "$( DPRINT ss -blunt -p | grep -i $serviceAlias )" ] ; then
           	 
            	printf "Active on port(s) ${YELLOW}$(ss -blunt -p | grep -i "$serviceAlias\|$serviceToCheckExists"| awk 'BEGIN {ORS=" and " } {print $1,$5}' | sed 's/\(.*\)and /\1\n\n/')${NC}\n\n"
        	fi

    	fi
	elif echo "$serviceList" | grep -qi "$serviceToCheckExists" ; then
    	printf "\n\n${BLUE}[+] $serviceToCheckExists is on this machine${NC}\n\n"

    	if [ "$( DPRINT netstat -tulpn | grep -i $serviceToCheckExists )" ] ; then
           	 
            	printf "Active on port(s) ${YELLOW}$(netstat -tulpn | grep -i $serviceToCheckExists| awk 'BEGIN {ORS=" and "} {print $1, $4}' | sed 's/\(.*\)and /\1\n\n/')${NC}\n\n"
   	 
    	elif [ "$( DPRINT ss -blunt -p | grep -i $serviceToCheckExists )" ] ; then
           	 
            	printf "Active on port(s) ${YELLOW}$(ss -blunt -p | grep -i $serviceToCheckExists| awk 'BEGIN {ORS=" and " } {print $1,$5}' | sed 's/\(.*\)and /\1\n\n/')${NC}\n\n"
    	fi
	fi
}
if checkService "$SERVICES"  'docker' | grep -qi "is on this machine"; then
	checkService "$SERVICES"  'docker'

	ACTIVECONTAINERS=$( docker ps )
	if [ -n "$ACTIVECONTAINERS" ]; then
    	echo "Current Active Containers"
    	printf "${ORAG}$ACTIVECONTAINERS${NC}\n\n"
	fi

	ANONMOUNTS=$( docker ps -q | DPRINT xargs -n 1 docker inspect --format '{{if .Mounts}}{{.Name}}: {{range .Mounts}}{{.Source}} -> {{.Destination}}{{end}}{{end}}' | grep -vE '^$' | sed 's/^\///g' )
	if [ -n "$ANONMOUNTS" ]; then
    	echo "Anonymous Container Mounts (host -> container)"
    	printf "${ORAG}$ANONMOUNTS${NC}\n\n"
	fi

	VOLUMES="$( DPRINT docker volume ls --format "{{.Name}}" )"
	if [ -n "$VOLUMES" ]; then
    	echo "Volumes"
    	for v in $VOLUMES; do
        	container=$( DPRINT docker ps -a --filter volume=$v --format '{{.Names}}' | tr '\n\n' ',' | sed 's/,$//g' )
        	if [ -n "$container" ]; then
            	mountpoint=$( echo $( DPRINT docker volume inspect --format '{{.Name}}: {{.Mountpoint}}' $v ) | awk -F ': ' '{print $2}' )
            	printf "${ORAG}$v -> $mountpoint used by $container${NC}"
        	fi
    	done
    	echo ""
	fi
fi
if checkService "$SERVICES"  'nginx' | grep -qi "is on this machine"; then
	checkService "$SERVICES"  'nginx'
	NGINXCONFIG=$(tail -n +1 /etc/nginx/sites-enabled/* | grep -v '#'  | grep -E '==>|server|^[^[\t]listen|^[^[\t]root|^[^[\t]server_name|proxy_*')
	printf "\n\n[!] Configuration Details\n\n"
	printf "${ORAG}$NGINXCONFIG${NC}"
	NGINX=true
fi
if checkService "$SERVICES"  'apache2' | grep -qi "is on this machine"; then
	checkService "$SERVICES"  'apache2'
	APACHE2VHOSTS=$(tail -n +1 /etc/apache2/sites-enabled/* | grep -v '#' |grep -E '==>|VirtualHost|^[^[\t]ServerName|DocumentRoot|^[^[\t]ServerAlias|^[^[\t]*Proxy*')
	printf "\n\n[!] Configuration Details\n\n"
	printf "${ORAG}$APACHE2VHOSTS${NC}"
	APACHE2=true
fi

