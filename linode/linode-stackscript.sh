#! /bin/bash
# <UDF name="MY_HOSTNAME" Label="Hostname" />

exec &> $HOME/stackscript.log

# Update everything
echo "System update"
yum -yq update

echo "Installing build tools"
yum -yq install gcc gcc-c++ autoconf automake

# Configure UTC timezone
echo "Configuring timezone"
mv /etc/localtime /etc/localtime.orig
cp /usr/share/zoneinfo/UTC /etc/localtime

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

# Configure huge pages
echo "vm.nr_hugepages = 292" >> /etc/sysctl.conf
# TODO: Configure deadline scheduler
# TODO: Configure iptables for firewall

# Install git from epel
rpm -Uv http://download.fedora.redhat.com/pub/epel/5/x86_64/epel-release-5-4.noarch.rpm
yum -y install git

echo "Done"
touch DONE
