#!/bin/bash

## FUNCTIONS A-Z

install_riak() {
  riak_kv_filename="riak-kv-2.0.6-arm.tar.gz"
  riak_kv_folder="riak-kv-2.0.6"
  # todo: folder should be generated from filename so it isn't required
  
  if [[ ! -r /home/basho/${riak_kv_filename} ]]; then
    echo "Downloading ${riak_kv_filename}..."
    wget https://riakpi.s3.amazonaws.com/${riak_kv_filename} -O /home/basho/${riak_kv_filename}
  fi
  echo "Unpacking ${riak_kv_filename}..."
  rm -rf /home/basho/${riak_kv_folder}
  tar xf /home/basho/${riak_kv_filename} -C /home/basho && e_success "Riak unpacked to /home/basho/${riak_kv_folder}"
  chown -R basho:sudo /home/basho/${riak_kv_folder}

  echo "export WAIT_FOR_ERLANG=30" > /etc/profile.d/wait_for_erlang.sh
  source /etc/profile.d/wait_for_erlang.sh
  
  export riak_ipaddr=`ifconfig eth0 | grep 'inet addr:' | cut -d: -f2 | cut -d " " -f1`
  export riak_hostname=`hostname --fqdn`
  ln -s /home/basho/${riak_kv_folder} /home/basho/riak
  
  echo "nodename = riak@${riak_hostname}" >> /home/basho/riak/etc/riak.conf
  echo "anti_entropy = passive" >> /home/basho/riak/etc/riak.conf
  echo "listener.http.internal = ${riak_ipaddr}:8098" >> /home/basho/riak/etc/riak.conf
  echo "listener.protobuf.internal = ${riak_ipaddr}:8087" >> /home/basho/riak/etc/riak.conf
  echo "ring_size = 32" >> /home/basho/riak/etc/riak.conf
  # todo: enable claim v3 in advanced.config as 32/5 results in unsafe distribution

  if [[ `grep -c /home/basho/riak/bin ~/.bashrc` -eq 0 ]]; then
    echo "export PATH=${PATH}:/home/basho/riak/bin" >> ~/.bashrc \
    && e_success "Added /home/basho/riak/bin to PATH"
  fi
}

install_riak_explorer() {
  e_warning "Installing Riak Explorer"
  # todo: actually install riak control
}

## SCRIPT

script_path="$(cd $(dirname ${0}) && pwd)"
source "${script_path}/../.riak-pi-include"

run_as_superuser
install_riak
install_riak_explorer
