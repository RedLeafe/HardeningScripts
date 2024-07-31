#!/bin/sh
# @d_tranman/Nigel Gerald/Nigerald

ipt=$(command -v iptables || command -v /sbin/iptables || command -v /usr/sbin/iptables)

$ipt -P OUTPUT ACCEPT


RHEL(){
    # Fix config
    if command -v authconfig >/dev/null; then
        authconfig --updateall

        # Fix modules
        # /usr/lib64/security
        yum -y reinstall pam 
    else
        echo "No authconfig, cannot fix pam here"
    fi

}

DEBIAN(){
    # Fix config
    DEBIAN_FRONTEND=noninteractive 
    pam-auth-update --force

    # Fix modules
    # /lib/x86_64-linux-gnu/security
    # /usr/lib/x86_64-linux-gnu/security
    apt-get -y --reinstall install libpam-runtime libpam-modules
}

UBUNTU(){
    DEBIAN
}

ALPINE(){
    if [ ! -d /etc/pam.d ]; then
        echo "PAM is not installed"
    else
        # Fix modules and config
        # /lib/security
        apk fix --purge linux-pam
        for file in $( find /etc/pam.d -name *.apk-new | xargs -0 echo ); do
            mv $file $( echo $file | sed 's/.apk-new//g' )
        done
    fi
}

if command -v yum >/dev/null ; then
    RHEL
elif command -v apt-get >/dev/null ; then
    if $( cat /etc/os-release | grep -qi Ubuntu ); then
        UBUNTU
    else
        DEBIAN
    fi
elif command -v apk >/dev/null ; then
    ALPINE
else
    echo "Unknown OS, not fixing PAM"
fi

$ipt -P OUTPUT DROP

echo PAM Completed