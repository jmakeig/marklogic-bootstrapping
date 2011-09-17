#! /bin/bash
# <UDF name="MY_HOSTNAME" Label="Hostname" />

# Log everything from this script to stacksript.log
exec &> $HOME/stackscript.log

# Update the OS
echo "System update"
yum -yq update

# Get the tools necessary for compiling code
echo "Installing build tools"
yum -yq install gcc gcc-c++ autoconf automake

echo "Installing system monitoring tools"
yum -yq install sysstat

# Upgrade tar into /usr/local/bin
echo "Installing tar v1.26 to /usr/local/bin"
cd $HOME
curl -O http://ftp.gnu.org/gnu/tar/tar-1.26.tar.gz
tar -xzf tar-1.26.tar.gz
cd tar-1.26
# tar doesn't like to be installed as root
export FORCE_UNSAFE_CONFIGURE=1
./configure
make
make install
cd ..
rm -rf tar-1.26
rm tar-1.26.tar.gz

# Configure UTC timezone
echo "Configuring timezone"
mv /etc/localtime /etc/localtime.orig
cp /usr/share/zoneinfo/UTC /etc/localtime

echo "Setting system configuration: hostname, timezone, huge pages, scheduler"

# Set host name
function system_primary_ip {
  # returns the primary IP assigned to eth0
  echo $(ifconfig eth0 | awk -F: '/inet addr:/ {print $2}' | awk '{ print $1 }')
}

function get_rdns {
  # calls host on an IP address and returns its reverse dns
  if [ ! -e /usr/bin/host ]; then
    yum -yq install bind-utils > /dev/null
  fi
  echo $(host $1 | awk '/pointer/ {print $5}' | sed 's/\.$//')
}

function get_rdns_primary_ip {
        # returns the reverse dns of the primary IP assigned to this system
        echo $(get_rdns $(system_primary_ip))
}


function set_hostname {
  # set the hostname
  echo setting hostname to $1
  echo "HOSTNAME=$1" >> /etc/sysconfig/network
  hostname "$1"

  # update /etc/hosts
  echo $(system_primary_ip) $(get_rdns_primary_ip) $(hostname) >> /etc/hosts
}

echo "Setting hostname to $MY_HOSTNAME"
set_hostname $MY_HOSTNAME


# Configure huge pages
# This number came out of the MarkLogic error log
#echo "vm.nr_hugepages = 292" >> /etc/sysctl.conf

# TODO: Configure deadline scheduler
# http://lists.centos.org/pipermail/centos/2009-November/085311.html
#   for dev in xvda; do
#       echo deadline >/sys/block/${dev}/queue/scheduler
#   done
# /dev/xvda is the root device
#echo "Setting deadline scheduler on /sys/block/xvda"
#echo "echo deadline > /sys/block/xvda/queue/scheduler" >> /etc/rc.local

# TODO: Configure iptables for firewall

echo "Installing supporting software"

# Install MarkLogic
echo "Installing MarkLogic 4.2-6.1"
yum -yq install gdb
# curl -O http://developer.marklogic.com/download/binaries/4.2/MarkLogic-4.2-6.1.x86_64.rpm
rpm -iv http://developer.marklogic.com/download/binaries/4.2/MarkLogic-4.2-6.1.x86_64.rpm
# /etc/init.d/MarkLogic start

# Install git from epel
rpm -Uv http://download.fedora.redhat.com/pub/epel/5/x86_64/epel-release-5-4.noarch.rpm
yum -y install git

# Install node.js
echo "Installing OpenSSL development tools for Node.js"
yum -yq install openssl-devel

# Node.js
# https://github.com/joyent/node/wiki/Installation
echo "Installing Node.js 0.4.11"
cd $HOME
git clone --depth 1 git://github.com/joyent/node.git # or git clone git://github.com/joyent/node.git if you want to checkout a stable tag
cd node
git checkout v0.4.11 # optional.  Note that master is unstable.
# export JOBS=2 # optional, sets number of parallel commands.
mkdir ~/local
./configure --prefix=$HOME/local/node
make
make install
# This doesn't work because the script probably isn't running as root
echo 'export PATH=$HOME/local/node/bin:$PATH' >> ~/.bashrc
echo 'export NODE_PATH=$HOME/local/node:$HOME/local/node/lib/node_modules' >> ~/.bashrc
source ~/.bashrc

# NPM
echo "Installing npm"
curl http://npmjs.org/install.sh | clean=yes sh
npm config set tar=/usr/local/bin/tar

# Proxy reqirements:
#   HTTP                    (MUST)
#   Usable configuration    (MUST)
#   Streaming uploads       (MUST)
#   SSL (most don't)        (SHOULD)
#   Websockets              (SHOULD)
#   Cache integrated        (MAY)

# Node.js http-proxy
# https://githubm.com/nodejitsu/http-proxy
npm install http-proxy

# Install nginx
# yum -yq install nginx

# Install HAProxy
# yum -yq install haproxy

# Install Varnish
# https://www.varnish-cache.org/installation/redhat
# rpm --nosignature -i http://repo.varnish-cache.org/redhat/varnish-3.0/el5/noarch/varnish-release-3.0-1.noarch.rpm
# yum install varnish

# Install socket.io for Websockets
# https://github.com/LearnBoost/Socket.IO
npm install socket.io

# Install Haraka for mail listener
# https://github.com/baudehlo/Haraka
npm install -g Haraka


echo "Done"
