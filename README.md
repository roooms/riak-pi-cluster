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
10.0.0.110	utility utility.pi
10.0.0.111	riak1 riak1.pi
10.0.0.112	riak2 riak2.pi
10.0.0.113	riak3 riak3.pi
10.0.0.114	riak4 riak4.pi
10.0.0.115	riak5 riak5.pi
```

If you edit your own hosts file you can use the above hostnames; 
otherwise you need to use IPs to connect to the nodes.

## Installation

### bootstrap.sh - for every node

* Expects to be run with sudo on a vanilla install of raspbian
* Creates a `basho` user with the password `demo-cluster`
* Sets each nodes hostname and IP address based on hardcoded MAC address
* Updates the ulimit and sets some recommended sysctl tunings for Riak

### install-riak.sh - for riak nodes

* Expects to be run _after_ bootstrap.sh using updated hostname and IP address
* (If not available locally) downloads pre-built version of Riak 2.0.6 for ARM
* Unpacks Riak to `/home/basho/riak`
* Configures Riak with settings suitable for Raspberry Pi specifications
* Configures Riak Control on riak1.pi
* _Does not cluster the nodes_

### install-collectd.sh - for riak nodes

* Expects to be run _after_ bootstrap.sh using updated hostname and IP address
* Installs collectd
* Configures collectd to `curl_json` the Riak `/stats` endpoint
* Configures collectd to send data to graphite on the utility.pi node 

### install-haproxy.sh - for utility node

* Expects to be run _after_ bootstrap.sh using updated hostname and IP address
* Installs haproxy
* Configures an admin view on port `8888` with username `admin` and password
`admin`
* Configures two haproxy frontends listening on all available IP addresses
  * Protocol buffers frontend on port `8087`
  * HTTP frontend on port `8098`
* Configures corresponding haproxy backends comprising the riak nodes

## Logins

The logins setup by the scripts are summarised here:

* Linux login: `basho` `demo-cluster`
* HA Proxy Status: `http://utility.pi:8888` `admin` `admin`
* Graphite: `http://utility.pi` `root` `password`
* Grafana: `http://utility.pi:3000` `admin` `admin`
