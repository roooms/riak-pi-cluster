#!/bin/sh

RIAK_ETH="eth0"
RIAK_IP=`ifconfig $RIAK_ETH | grep 'inet addr:' | cut -d: -f2 | cut -d " " -f1`
HOSTNAME=`hostname --fqdn`

echo "Enter the Graphite host IP address:"
read GRAPHITE_IP

## install collectd
sudo apt-get update
sudo apt-get install collectd collectd-utils -y
sudo cp etc_collectd_collectd.conf /etc/collectd/collectd.conf

sed -e "s/pinode/$HOSTNAME/g" \
    -e "s/10.0.0.11/$RIAK_IP/g" \
    -e "s/10.0.0.10/$GRAPHITE_IP/g" \
    -e "s/ethX/$RIAK_ETH/g" \
    etc_collectd_collectd.conf | sudo tee /etc/collectd/collectd.conf

sudo service collectd stop
sleep 3
sudo service collectd start
