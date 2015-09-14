#!/bin/sh

# install and configure haproxy
sudo apt-get install haproxy --yes
sudo cp /etc/haproxy/haproxy.cfg /etc/haproxy/haproxy.cfg.bak
sudo cp /home/basho/riak-pi-cluster/utility-node/haproxy.cfg /etc/haproxy/haproxy.cfg
sudo vim /etc/default/haproxy # changed ENABLED=0 to ENABLED=1
sudo service haproxy start