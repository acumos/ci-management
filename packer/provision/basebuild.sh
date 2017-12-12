#!/bin/bash

# vim: ts=4 sw=4 sts=4 et tw=72 :

rh_systems() {

}

ubuntu_systems() {

}

opensuse_systems() {

}

all_systems() {

    echo 'Configure keep alive to prevent timeout during testing'
    local SSH_CFG=/etc/ssh/ssh_config
    echo "TCPKeepAlive        true" | sudo tee -a ${SSH_CFG} >/dev/null 2>&1
    echo "ServerAliveCountMax 30"   | sudo tee -a ${SSH_CFG} >/dev/null 2>&1
    echo "ServerAliveInterval 10"   | sudo tee -a ${SSH_CFG} >/dev/null 2>&1

    # Following installs hashicorp's packer binary which is required  for
    # ci-management-{verify,merge}-packer jobs
    mkdir /tmp/packer.io
    cd /tmp/packer.io
    wget https://releases.hashicorp.com/packer/0.12.2/packer_0.12.2_linux_amd64.zip
    unzip packer_0.12.2_linux_amd64.zip -d /usr/local/bin/
    # note: rename to packer.io to avoid conflict with cracklib packer
    mv /usr/local/bin/packer /usr/local/bin/packer.io

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
