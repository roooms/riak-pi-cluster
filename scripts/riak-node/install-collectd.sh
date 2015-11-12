#!/bin/bash

## FUNCTIONS A-Z

install_collectd() {
  node_ipaddr=`ifconfig eth0 | grep 'inet addr:' | cut -d: -f2 | cut -d " " -f1`
  node_hostname=`hostname --fqdn`
  graphite_ipaddr=`grep utility /etc/hosts | cut -f1`
  apt-get update --fix-missing
  apt-get install collectd collectd-utils --yes \
  && e_success "Installed collectd"
  sed -e "s/pinode/${node_hostname}/g" \
      -e "s/10.0.0.11/${node_ipaddr}/g" \
      -e "s/10.0.0.10/${graphite_ipaddr}/g" \
      -e "s/ethX/eth0/g" \
      /usr/share/riak-pi-cluster/riak-node/etc_collectd_collectd.conf > /etc/collectd/collectd.conf
  service collectd stop
  sleep 3
  service collectd start \
  && e_success "Started collectd"
}

## SCRIPT

script_path="$(cd $(dirname ${0}) && pwd)"
source "${script_path}/../.riak-pi-include"

run_as_superuser
install_collectd
