#!/bin/bash

# vim: ts=4 sw=4 sts=4 et tw=72 :

rh_systems() {

    echo 'No extra changes needed at this time'

}

ubuntu_systems() {

    echo 'No extra changes needed at this time'

}

opensuse_systems() {

    echo 'No extra changes needed at this time'

}

all_systems() {

    echo 'Configure keep alive to prevent timeout during testing'
    local SSH_CFG=/etc/ssh/ssh_config
    echo "TCPKeepAlive        true" | sudo tee -a ${SSH_CFG} >/dev/null 2>&1
    echo "ServerAliveCountMax 30"   | sudo tee -a ${SSH_CFG} >/dev/null 2>&1
    echo "ServerAliveInterval 10"   | sudo tee -a ${SSH_CFG} >/dev/null 2>&1

}

echo "---> Detecting OS"
ORIGIN=$(facter operatingsystem | tr '[:upper:]' '[:lower:]')

case "${ORIGIN}" in
    fedora|centos|redhat)
        echo "---> RH type system detected"
        rh_systems
    ;;
    ubuntu)
        echo "---> Ubuntu system detected"
        ubuntu_systems
    ;;
    opensuse)
        echo "---> openSuSE system detected"
        opensuse_systems
    ;;
    *)
        echo "---> Unknown operating system"
    ;;
esac

# execute steps for all systems
all_systems
