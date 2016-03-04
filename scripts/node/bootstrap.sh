#!/bin/bash

## FUNCTIONS A-Z

bootstrap_complete() {
  e_warning "Reboot required to apply hostname and IP address"
}

check_bootstrap() {
  cp -R ${script_path}/../../conf/. /usr/share/riak-pi-cluster/ \
  && chown -R root:root /usr/share/riak-pi-cluster \ 
  && e_success "Copied configuration files to /usr/share/riak-pi-cluster"
}

create_basho_user() {
  if [[ `grep -c basho /etc/passwd` -eq 0 ]]; then
    useradd basho -g sudo -m && e_success "Added basho user" \
    && echo "basho:demo-cluster" | chpasswd \
    && e_success "Set basho user password"
  fi
  if [[ `grep -c basho /etc/sudoers` -eq 0 ]]; then
    echo "basho ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers \
    && e_success "Added basho user to sudoers"
  fi
  if [[ ! -d /home/basho/.ssh ]]; then
    mkdir -m 700 /home/basho/.ssh
    cp /usr/share/riak-pi-cluster/node/demo_cluster_id /home/basho/.ssh/demo_cluster_id
    if [[ ! -f /home/basho/.ssh/authorized_keys ]]; then
      touch /home/basho/.ssh/authorized_keys && chmod 600 /home/basho/.ssh/authorized_keys
    fi
    if [[ `grep -c basho /home/basho/.ssh/authorized_keys` -eq 0 ]]; then
      cat /usr/share/riak-pi-cluster/node/demo_cluster_id.pub >> /home/basho/.ssh/authorized_keys \
      && e_success "Updated authorized_keys"
    fi
  fi
  if [[ ! -f /home/basho/.vimrc ]]; then
    cat > /home/basho/.vimrc << EOF 
syntax on
filetype on
au BufNewFile,BufRead app*.config set filetype=erlang
au BufNewFile,BufRead vm*.args set filetype=sh
EOF
  e_success "Created /home/basho/.vimrc"
  fi
  chown --recursive basho:sudo /home/basho/
}

pi_tweaks() {
  apt-get update --fix-missing
  apt-get install avahi-daemon iperf3 vim --yes
  rm -f /etc/skel/pistore.desktop
  rm -rf /opt/minecraft-pi
  rm -rf /opt/sonic-pi
  rm -rf /opt/Wolfram
  raspi-config --expand-rootfs
  echo "\
  arm_freq=1000
  core_freq=500
  sdram_freq=500
  over_voltage=2
  gpu_mem=16" >> /boot/config.txt # todo: make idempotent
}

update_etc_hosts() {
  cp /usr/share/riak-pi-cluster/node/etc_hosts /etc/hosts \
  && e_success "Updated /etc/hosts with cluster details"
}

update_hostname_and_ipaddr() {
  mac_address=`cat /sys/class/net/eth0/address`
  current_hostname=`hostname`
  current_eth0_ipaddr=`ifconfig eth0 | grep 'inet addr:' | cut -d: -f2 | cut -d " " -f1`
  utility_eth0_ipaddr="192.168.0.110"
  riak1_eth0_ipaddr="192.168.0.111"
  riak2_eth0_ipaddr="192.168.0.112"
  riak3_eth0_ipaddr="192.168.0.113"
  riak4_eth0_ipaddr="192.168.0.114"  
  riak5_eth0_ipaddr="192.168.0.115"  

  case "${mac_address}" in
    "b8:27:eb:fc:c5:10")
      new_hostname="utility"
      new_eth0_ipaddr="${utility_eth0_ipaddr}"
      ;;
    "b8:27:eb:a6:0d:2f")
      new_hostname="riak1"
      new_eth0_ipaddr="${riak1_eth0_ipaddr}"
      ;;
    "b8:27:eb:db:53:2e")
      new_hostname="riak2"
      new_eth0_ipaddr="${riak2_eth0_ipaddr}"
      ;;
    "b8:27:eb:9e:ea:52")
      new_hostname="riak3"
      new_eth0_ipaddr="${riak3_eth0_ipaddr}"
      ;;
    "b8:27:eb:d3:24:30")
      new_hostname="riak4"
      new_eth0_ipaddr="${riak4_eth0_ipaddr}"
      ;;
    "b8:27:eb:e4:bf:27")
      new_hostname="riak5"
      new_eth0_ipaddr="${riak5_eth0_ipaddr}"
      ;;
    *) # catch all
      new_hostname=$current_hostname
      new_eth0_ipaddr=$current_eth0_ipaddr
      ;;
  esac

  sed -i "s/127.0.1.1.*$/127.0.1.1\t${new_hostname}.local ${new_hostname}/" /etc/hosts \
  && e_success "Updated /etc/hosts with hostname"

  echo ${new_hostname} > /etc/hostname \
  && e_success "Reset hostname: ${new_hostname}"

  sed -e "s/static_placeholder/${new_eth0_ipaddr}/" \
  /usr/share/riak-pi-cluster/node/etc_network_interfaces > /etc/network/interfaces \
  && e_success "Reset IP address: ${new_eth0_ipaddr}"
}

update_sysctl() {
  if [[ `grep -c "somaxconn" /etc/sysctl.conf` -eq 0 ]]; then
    echo "\
vm.swappiness = 0
net.core.wmem_default = 8388608
net.core.rmem_default = 8388608
net.core.wmem_max = 8388608
net.core.rmem_max = 8388608
net.core.netdev_max_backlog = 10000
net.core.somaxconn = 4000
net.ipv4.tcp_max_syn_backlog = 40000
net.ipv4.tcp_fin_timeout = 15
net.ipv4.tcp_tw_reuse = 1
net.core.rmem_max = 134217728
net.core.wmem_max = 134217728
net.ipv4.tcp_mem = 134217728 134217728 134217728
net.ipv4.tcp_rmem = 4096 277750 134217728
net.ipv4.tcp_wmem = 4096 277750 134217728
net.core.netdev_max_backlog = 300000" \
  >> /etc/sysctl.conf && e_success "Updated /etc/sysctl.conf"
    sysctl -p 
  fi
}

update_ulimits() {
  if [[ `grep -c "nofile" /etc/security/limits.conf` -lt 4 ]]; then
    echo "\
* soft nofile 131072
* hard nofile 131072
root soft nofile 131072
root hard nofile 131072" \
    >> /etc/security/limits.conf && e_success "Updated ulimits"
  fi
  if [[ `grep -c "session    required    pam_limits.so" /etc/pam.d/common-session` -eq 0 ]]; then
    echo "session    required    pam_limits.so" >> /etc/pam.d/common-session
  fi
  if [[ `grep -c "session    required    pam_limits.so" /etc/pam.d/common-session-noninteractive` -eq 0 ]]; then
    echo "session    required    pam_limits.so" >> /etc/pam.d/common-session-noninteractive
  fi
}

## SCRIPT

script_path="$(cd $(dirname ${0}) && pwd)"
source "${script_path}/../.riak-pi-include"

check_bootstrap
run_as_superuser
pi_tweaks
create_basho_user
update_etc_hosts
update_hostname_and_ipaddr
update_sysctl
update_ulimits
bootstrap_complete
