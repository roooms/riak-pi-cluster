#!/bin/sh

# install and configure haproxy
sudo apt-get install haproxy --yes
sudo cp /etc/haproxy/haproxy.cfg /etc/haproxy/haproxy.cfg.bak
sudo cp /home/basho/riak-pi-cluster/utility-node/haproxy.cfg /etc/haproxy/haproxy.cfg
sudo sed -i "s/ENABLED=0/ENABLED=1/g" /etc/default/haproxy
sudo service haproxy start
