#!/bin/bash

# jmakeig-centos6.localdomain

# log everything to a file
exec &> $HOME/stackscript.log

# yum -y: assume yes, -q: quiet
yum -yq update
yum -yq groupinstall 'Development Tools'
yum -yq install glibc glibc.i686 lsb
# rpm -iv http://developer.marklogic.com/download/binaries/6.0/MarkLogic-6.0-2.1.x86_64.rpm
curl -s -S -O -XPOST -d'email=jmakeig@marklogic.com&pass=asdfasdf' 'https://developer.marklogic.com/download/binaries/6.0/MarkLogic-6.0-2.x86_64.rpm'
rpm -iv MarkLogic-6.0-2.x86_64.rpm
rm MarkLogic-6.0-2.x86_64.rpm
/etc/init.d/MarkLogic start

# Set Linux huge pages
echo "vm.nr_hugepages = 292" >> /etc/sysctl.conf
sysctl -p

# http://www.linode.com/wiki/index.php/CentOS_IPTables_sh
# http://wiki.centos.org/HowTos/Network/IPTables

# Flush all current rules from iptables
iptables -F

# Allow SSH connections on tcp port 22
# This is essential when working on remote servers via SSH to prevent locking yourself out of the system
iptables -A INPUT -p tcp --dport 22 -j ACCEPT

# Set default policies for INPUT, FORWARD and OUTPUT chains
iptables -P INPUT DROP
iptables -P FORWARD DROP
iptables -P OUTPUT ACCEPT

# Set access for localhost
iptables -A INPUT -i lo -j ACCEPT

# Accept packets belonging to established and related connections
iptables -A INPUT -j ACCEPT -m state --state ESTABLISHED,RELATED
iptables -A FORWARD -j ACCEPT -m state --state ESTABLISHED,RELATED

# Note eth0 interface
iptables -A INPUT -j ACCEPT -i eth0 -p tcp -m multiport --dport 80,443,7999,8000,8001,8002
iptables -A INPUT -p icmp -m icmp --icmp-type 8 -j ACCEPT

/sbin/service iptables save
# iptables -L -v






###########################################
# nginx

# Regular expression library for rewrite rules
yum -yq install pcre-devel
# curl -L -o pcre-8.32.tar.gz http://sourceforge.net/projects/pcre/files/pcre/8.32/pcre-8.32.tar.gz/download
# tar -xzf pcre-8.32.tar.gz

# Compression algorithm for gzip
yum -yq zlib-devel
# curl -O http://zlib.net/zlib-1.2.7.tar.gz
# tar -xzf zlib-1.2.7.tar.gz

curl -O http://nginx.org/download/nginx-1.3.13.tar.gz
tar -xzf nginx-1.3.13.tar.gz
cd nginx-1.3.13

yum -yq install openssl-devel

./configure --with-http_ssl_module --with-pcre=../pcre-8.32 --with-zlib=../zlib-1.2.7
make
make install

ln -s /usr/local/nginx/sbin/nginx /usr/bin/nginx

mkdir /etc/nginx
mkdir /var/log/nginx
mkdir /

# http://wiki.nginx.org/CommandLine
# /usr/bin/nginx -c /etc/nginx/nginx.conf -g "pid /var/run/nginx.pid; worker_processes 2;"

# rsync -v ./nginx/* root@isopagination:/etc/nginx/




