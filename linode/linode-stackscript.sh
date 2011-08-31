#!/bin/bash
# Copyright 2011, Justin Makeig <justin-public+githug@makeig.com>
# 
#    Licensed under the Apache License, Version 2.0 (the "License");
#    you may not use this file except in compliance with the License.
#    You may obtain a copy of the License at
# 
#        http://www.apache.org/licenses/LICENSE-2.0
# 
#    Unless required by applicable law or agreed to in writing, software
#    distributed under the License is distributed on an "AS IS" BASIS,
#    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#    See the License for the specific language governing permissions and
#    limitations under the License.


# See https://wiki.marklogic.com/display/rootwiki/Checklist+for+installing+and+configuring+MarkLogic+Server+on+Redhat%2C+CentOS+or+Fedora

# returns the primary IP assigned to eth0
function system_primary_ip {
  echo $(ifconfig eth0 | awk -F: '/inet addr:/ {print $2}' | awk '{ print $1 }')
}

# calls host on an IP address ($1) and returns its reverse dns
function get_rdns {
  if [ ! -e /usr/bin/host ]; then
    yum -yq install bind-utils > /dev/null
  fi
  echo $(host $1 | awk '/pointer/ {print $5}' | sed 's/\.$//')
}

# returns the reverse dns of the primary IP assigned to this system
function get_rdns_primary_ip {
        echo $(get_rdns $(system_primary_ip))
}


# Sets the hostname to $1, e.g. example.com
function set_hostname {
  echo "HOSTNAME=$1" >> /etc/sysconfig/network
  hostname "$1"

  # update /etc/hosts
  echo $(system_primary_ip) $(get_rdns_primary_ip) $(hostname) >> /etc/hosts
}

yum -y update

# Set the hostname
set_hostname $1

# Configure UTC timezone
mv /etc/localtime /etc/localtime.orig
cp /usr/share/zoneinfo/UTC /etc/localtime

# Configure huge pages
echo "vm.nr_hugepages = 292" >> /etc/sysctl.conf
# TODO: Configure deadline scheduler
# TODO: Configure iptables for firewall

# Install MarkLogic 4.2-6.1
rpm -iv http://developer.marklogic.com/download/binaries/4.2/MarkLogic-4.2-6.1.x86_64.rpm


# Install Varnish
rpm --nosignature -i http://repo.varnish-cache.org/redhat/varnish-3.0/el5/noarch/varnish-release-3.0-1.noarch.rpm
yum -y install varnish
# TODO: Configure varnish

# Install git from epel
rpm -Uv http://download.fedora.redhat.com/pub/epel/5/x86_64/epel-release-5-4.noarch.rpm
yum -y install git

# Install Node

# Install NPM

# Install Haraka
# npm install -g Haraka
# see also https://github.com/maxogden/haraka-couchdb
# curl http://npmjs.org/install.sh | sh
