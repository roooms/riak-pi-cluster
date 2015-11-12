#!/bin/bash

## FUNCTIONS A-Z

install_riak() {
  if [[ ! -r /home/basho/riak-2.0.6-arm.tar.gz ]]; then
    echo "Downloading riak-2.0.6-arm archive..."
    wget https://s3-eu-west-1.amazonaws.com/riakpi/riak-2.0.6-arm.tar.gz -O /home/basho/riak-2.0.6-arm.tar.gz
  fi
  echo "Unpacking riak-2.0.6-arm archive..."
  rm -rf /home/basho/riak
  tar xf /home/basho/riak-2.0.6-arm.tar.gz -C /home/basho && e_success "Riak unpacked to /home/basho/riak"
  chown -R basho:sudo /home/basho/riak
  export riak_ipaddr=`ifconfig eth0 | grep 'inet addr:' | cut -d: -f2 | cut -d " " -f1`
  export riak_hostname=`hostname --fqdn`
  echo "export WAIT_FOR_ERLANG=30" > /etc/profile.d/wait_for_erlang.sh
  source /etc/profile.d/wait_for_erlang.sh
  
  echo "nodename = riak@${riak_hostname}" >> /home/basho/riak/etc/riak.conf
  echo "anti_entropy = passive" >> /home/basho/riak/etc/riak.conf
  echo "listener.http.internal = ${riak_ipaddr}:8098" >> /home/basho/riak/etc/riak.conf
  echo "listener.protobuf.internal = ${riak_ipaddr}:8087" >> /home/basho/riak/etc/riak.conf
  echo "ring_size = 32" >> /home/basho/riak/etc/riak.conf
}

riak_control() {
  e_warning "Installing Riak Control"
  # todo: actually install riak control
}

## SCRIPT

script_path="$(cd $(dirname ${0}) && pwd)"
source "${script_path}/../.riak-pi-include"

run_as_superuser
install_riak
riak_control
