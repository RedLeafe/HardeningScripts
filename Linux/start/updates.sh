#!/bin/sh
# @d_tranman/Nigel Gerald/Nigerald and c0ve

ORAG='\033[0;33m'
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;36m'
NC='\033[0m'

RHEL(){
    yum check-update -y >/dev/null
    yum install net-tools iproute sed curl tmux wget bash -y > /dev/null
    yum install iptraf -y >/dev/null

    yum install auditd -y > /dev/null
    yum install rsyslog -y > /dev/null
}

DEBIAN(){
    apt-get -qq update >/dev/null
    apt-get -qq install net-tools iproute2 sed curl tmux wget bash -y >/dev/null
    apt-get -qq install iptraf -y >/dev/null

    apt-get -qq install auditd rsyslog -y >/dev/null
}

UBUNTU(){
  DEBIAN
}

ALPINE(){
    echo "http://mirrors.ocf.berkeley.edu/alpine/v3.16/community" >> /etc/apk/repositories
    apk update >/dev/null
    apk add iproute2 net-tools curl tmux wget bash iptraf-ng iptables util-linux-misc >/dev/null

    apk add audit rsyslog >/dev/null

}

SLACK(){
  echo "Slack is cringe"
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
elif command -v slapt-get >/dev/null || (cat /etc/os-release | grep -i slackware >/dev/null) ; then
    SLACK
fi

printf "\n${RED}Updates Finished${NC}\n"