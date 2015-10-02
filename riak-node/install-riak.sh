#!/bin/sh

# install riak
wget https://s3-eu-west-1.amazonaws.com/riakpi/riak-2.0.6-arm.tar.gz
tar xf riak-2.0.6-arm.tar.gz

export RIAK_ETH="eth0"
export RIAK_IP=`ifconfig $RIAK_ETH | grep 'inet addr:' | cut -d: -f2 | cut -d " " -f1`
export RIAK_HOSTNAME=`hostname --fqdn`
export WAIT_FOR_ERLANG=30

echo "nodename = riak@$RIAK_HOSTNAME" >> /home/basho/riak/etc/riak.conf
echo "anti_entropy = passive" >> /home/basho/riak/etc/riak.conf
echo "listener.http.internal = $RIAK_IP:8098" >> /home/basho/riak/etc/riak.conf
echo "listener.protobuf.internal = $RIAK_IP:8087" >> /home/basho/riak/etc/riak.conf
echo "ring_size = 32" >> /home/basho/riak/etc/riak.conf