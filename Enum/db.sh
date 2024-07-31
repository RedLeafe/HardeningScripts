#!/bin/sh
# @d_tranman/Nigel Gerald/Nigerald

IS_RHEL=false
IS_DEBIAN=false
IS_ALPINE=false
IS_SLACK=false

ORAG=''
GREEN=''
YELLOW=''
BLUE=''
RED=''
NC=''

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

if [ -n "$COLOR" ]; then
	ORAG='\033[0;33m'
	RED='\033[0;31m'
	GREEN='\033[0;32m'
	YELLOW='\033[1;33m'
	BLUE='\033[0;36m'
	NC='\033[0m'
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
sql_test(){

	if [ -f /lib/systemd/system/mysql.service ]; then
    	SQL_SYSD=/lib/systemd/system/mysql.service
	elif [ -f /lib/systemd/system/mariadb.service ]; then
    	SQL_SYSD=/lib/systemd/system/mariadb.service
	fi
    
	if [ -n "$SQL_SYSD" ]; then
    	SQL_SYSD_INFO=$( grep -RE '^(User=|Group=)' $SQL_SYSD )
	fi
    
	if [ -d /etc/mysql ]; then
    	SQLDIR=/etc/mysql
	elif [ -d /etc/my.cnf.d/ ]; then
    	SQLDIR=/etc/my.cnf.d/
	fi

	if [ -n "$SQLDIR" ]; then
    	SQLCONFINFO=$( DPRINT find $SQLDR *sql*.cnf *-server.cnf | sed 's/:user\s*/ ===> user /' | sed 's/bind-address\s*/ ===> bind-address /' )
	fi

	if [ -n "$SQLCONFINFO" ]; then
    	printf "${ORAG}$SQLCONFINFO${NC}"
	fi

	if [ -n "$SQL_SYSD_INFO" ]; then
    	printf "${ORAG}$SQL_SYSD:\n\n$SQL_SYSD_INFO${NC}\n\n"
	fi

	SQL_AUTH=1

	if mysql -uroot -e 'bruh' 2>&1 >/dev/null | grep -v '\[Warning\]' | grep -q 'bruh'; then
    	printf "${RED}Can login as root, with root and no password${NC}\n\n"
    	SQLCMD="mysql -uroot"
	fi

	if mysql -uroot -proot -e 'bruh' 2>&1 >/dev/null | grep -v '\[Warning\]' | grep -q 'bruh'; then
    	printf "${RED}Can login with root:root${NC}\n\n"
    	SQLCMD="mysql -uroot -proot"
	fi

	if mysql -uroot -ppassword -e 'bruh' 2>&1 >/dev/null | grep -v '\[Warning\]' | grep -q 'bruh'; then
    	printf "${RED}Can login with root:password${NC}\n\n"
    	SQLCMD="mysql -uroot -ppassword"
	fi

	if [ -n "$DEFAULT_PASS" ]; then
    	if mysql -uroot -p"$DEFAULT_PASS" -e 'bruh' 2>&1 >/dev/null | grep -v '\[Warning\]' | grep -q 'bruh'; then
        	printf "${RED}Can login with root:$DEFAULT_PASS${NC}\n\n"
        	SQLCMD="mysql -uroot -p$DEFAULT_PASS"
    	fi
	fi

	if [ -z "$SQLCMD" ]; then
    	SQL_AUTH=0
	fi
    
	if [ "$SQL_AUTH" = 1 ]; then
    	echo "SQL User Information"
    	printf "${ORAG}$( DPRINT $SQLCMD -t -e 'select user,host,plugin,authentication_string from mysql.user where password_expired="N";' )${NC}\n\n"
    	DATABASES=$( DPRINT $SQLCMD -t -e 'show databases' | grep -vE '^\|\s(mysql|information_schema|performance_schema|sys|test)\s+\|' )
    	if [ -n "$DATABASES" ]; then
        	echo "SQL Databases"
        	printf "${ORAG}$DATABASES${NC}\n\n"
    	fi
	else
    	echo "Cannot login with weak creds or default credentials"
	fi
}
if checkService "$SERVICES"  'mysql' | grep -qi "is on this machine"; then
	MYSQL=true
	checkService "$SERVICES"  'mysql'
	sql_test
fi

if checkService "$SERVICES"  'mariadb' | grep -qi "is on this machine"; then
	MARIADB=true
	checkService "$SERVICES"  'mariadb'
	sql_test
fi
if checkService "$SERVICES" 'mssql-server' | grep -qi "is on this machine" ; then
	sqlserver=true
	checkService "$SERVICES" 'mssql-server' 'sqlservr'
fi
if checkService "$SERVICES"  'postgres' | grep -qi "is on this machine" ; then
	POSTGRESQL=true
	checkService "$SERVICES" 'postgres' || checkService "$SERVICES" 'postgres' 'postmaster'
	PSQLHBA=$( grep -REvh '(#|^\s*$|replication)' $( DPRINT find /etc/postgresql/ /var/lib/pgsql/ /var/lib/postgres* -name pg_hba.conf | head -n 1 ) )
	printf "PostgreSQL Authentication Details\n\n"
	printf "${ORAG}$PSQLHBA${NC}\n\n"

	if DPRINT psql -U postgres -c '\q'; then
    	AUTH=1
    	DB_CMD=" psql -U postgres -c \l "
	elif DPRINT sudo -u postgres psql -c '\q'; then
    	AUTH=1
    	DB_CMD=" sudo -u postgres psql -c \l "
	fi
	if [ "$AUTH" = 1 ]; then
    	DATABASES="$( DPRINT $DB_CMD | grep -vE '^\s(postgres|template0|template1|\s+)\s+\|' | head -n -2 )"
    	if [ "$( echo "$DATABASES" | wc -l )" -gt 2 ]; then
        	echo "PostgreSQL Databases"
        	printf "${ORAG}$DATABASES${NC}\n\n"
    	fi
	fi
fi


