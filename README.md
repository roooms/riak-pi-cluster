# Riak Pi Cluster

Six Raspberry Pi computers running as a utility node and five Riak nodes.

## Introduction

This assumes all Raspberry Pi nodes are running Raspbian which comes 
pre-installed with some unnecessary software and a `pi` user. The `pi` user
has sudo rights, so this can be used for the initial setup.

Login with username:`pi` and password:`raspberry`. 

I recommend using something like [`csshX`](https://github.com/brockgr/csshx) to 
manage the cluster and run the install scripts.

## Pre-Install Configuration

The Riak Pi Cluster is expected to run as a standalone system with hardcoded IP 
addresses. These are defined in `conf/node/etc_hosts` which is copied to 
`/etc/hosts` on all nodes during "bootstrap".

You can edit the IP addresses in `conf/node/etc_hosts` but hostnames are fixed
and matched to node MAC addresses during "bootstrap".

Below is an example of a sane IP configuration. You should configure your
laptop (if you are also connecting to the switch) to use a neighbouring IP.

```
10.0.0.110	utility utility.local
10.0.0.111	riak1 riak1.local
10.0.0.112	riak2 riak2.local
10.0.0.113	riak3 riak3.local
10.0.0.114	riak4 riak4.local
10.0.0.115	riak5 riak5.local
```

The bootstrap script installs `avahi-daemon` which will avoid the need for additional hostname configuration.

## Installation

### scripts/node/bootstrap.sh - for every node

* Expects to be run as the `pi` user with sudo on a vanilla install of raspbian
* Creates a `basho` user with the password `demo-cluster` and installs `demo_cluster_id` ssh key
* Sets each nodes hostname and IP address based on hardcoded MAC address
* Updates the ulimit and sets some recommended sysctl tunings for Riak
* Copies necessary setup files to `/usr/share/riak-pi-cluster` for later use

### scripts/riak-node/install.sh - for riak nodes

* Expects to be run as the `basho` user _after_ bootstrap.sh using updated hostname and IP address
* Runs `scripts/riak-node/install-riak.sh`
* Runs `scripts/riak-node/install-collectd.sh`

#### `install-riak.sh`

* (If not available locally) downloads pre-built version of Riak 2.0.6 for ARM
* Unpacks Riak to `/home/basho/riak`
* Configures Riak with settings suitable for Raspberry Pi specifications
* Configures Riak Explorer on riak1.local
* _Does not cluster the nodes_

#### `install-collectd.sh`

* Expects to be run as the `basho` user _after_ bootstrap.sh using updated hostname and IP address
* Installs collectd
* Configures collectd to `curl_json` the Riak `/stats` endpoint
* Configures collectd to send data to graphite on the utility.local node 

### scripts/utility-node/install.sh - for utility node

* Expects to be run as the `basho` user _after_ bootstrap.sh using updated hostname and IP address
* Runs `scripts/utility-node/install-basho_bench.sh`
* Runs `scripts/utility-node/install-haproxy.sh`
* Runs `scripts/utility-node/install-jupyter.sh`
* Runs `scripts/utility-node/install-monitoring.sh`

#### `install-basho_bench.sh`

#### `install-haproxy.sh`

* Installs haproxy
* Configures an admin view on port `8888` with username `admin` and password
`admin`
* Configures two haproxy frontends listening on all available IP addresses
  * Protocol buffers frontend on port `8087`
  * HTTP frontend on port `8098`
* Configures corresponding haproxy backends comprising the riak nodes

#### `install-jupyter.sh`

* Installs Jupyter
* Should be started when required with `jupyter notebook --ip=0.0.0.0 --port=9999 --no-browser &`
* See logins below for access

#### `install-monitoring.sh`

## Logins & Services

The logins and services setup by the scripts are summarised here:

* Linux login: `basho` `demo-cluster`
* Graphite: `http://utility.local` `root` `password`
* Grafana: `http://utility.local:3000` `admin` `admin`
* HA Proxy Status: `http://utility.local:8888` `admin` `admin`
* Jupyter: `http://utility.local:9999`

----

* todo: document `install-basho_bench.sh`
* todo: document `install-monitoring.sh`
