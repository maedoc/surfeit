#!/bin/bash

function ensure_source()
{
    url=$1
    pushd /usr/src &> /dev/null
    curl -LO $url
    popd
}

set -eux

# config
prefix=/usr
munge_ver="0.5.13"

# global setup
mkdir -p $/src
yum install -y gcc make openssl-devel perl

# reinstall munge if service isn't ok
if ! systemctl status munged
then
    cd $prefix/src

    rm -rf ./munge-*
    ensure_source https://github.com/dun/munge/releases/download/munge-${munge_ver}/munge-${munge_ver}.tar.xz
    tar xJf munge-*.tar.xz
    cd munge-*/
    
    ./configure --prefix=$prefix --localstatedir=/var --sysconfdir=/etc
    make -j && make install
    ldconfig
    
    mkdir -p /etc/munge
    echo -n 'secret' | sha512sum | cut -d' ' -f1 > /etc/munge/munge.key
    chmod 600 /etc/munge/munge.key
    
    cp /{vagrant,etc/systemd/system}/munged.service
    systemctl daemon-reload 
    systemctl enable --now munged
fi

# reinstall slurm
if [[ -z `which sinfo` ]]
then
    cd $prefix/src
    ensure_source https://download.schedmd.com/slurm/slurm-17.11.9-2.tar.bz2
    tar xjf slurm-*.tar.bz2 
    cd slurm-*/
    ./configure --prefix=$prefix
    make -j
    make install
    echo '/usr/local/lib' >> /etc/ld.so.conf
    ldconfig
fi

# provide slurm.conf
if [[ ! -f /usr/etc/slurm.conf ]]
then
    cp /{vagrant,usr/etc}/slurm.conf
fi

# setup slurmctld service
if ! systemctl status slurmctld &> /dev/null
then
    cp /{vagrant,etc/systemd/system}/slurmctld.service
    systemctl daemon-reload
    systemctl enable --now slurmctld
fi

# setup slurmd service
if ! systemctl status slurmd &> /dev/null
then
    cp /{vagrant,etc/systemd/system}/slurmd.service
    systemctl daemon-reload
    systemctl enable --now slurmd
    systemctl start slurmd
    while ! scontrol update nodename=node state=idle; do sleep 1; done
fi

# update slurm.conf
if [[ /vagrant/slurm.conf -nt /usr/etc/slurm.conf ]]
then
    cp /{vagrant,usr/etc}/slurm.conf
    systemctl restart slurmd
    systemctl restart slurmctld
fi

