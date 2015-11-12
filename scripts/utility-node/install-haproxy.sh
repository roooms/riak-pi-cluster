#!/bin/bash

## FUNCTIONS A-Z

install_haproxy() {
  apt-get install haproxy --yes \
  && e_success "Installed haproxy"
  cp /etc/haproxy/haproxy.cfg /etc/haproxy/haproxy.cfg.bak
  cp /usr/share/riak-pi-cluster/utility-node/etc_haproxy_haproxy.cfg /etc/haproxy/haproxy.cfg \
  && e_success "Configured haproxy"
  service haproxy restart \
  && e_success "Started haproxy"
}

## SCRIPT

script_path="$(cd $(dirname ${0}) && pwd)"
source "${script_path}/../.riak-pi-include"

run_as_superuser
install_haproxy
