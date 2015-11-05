# Riak Pi Cluster

Six Raspberry Pi computers running as a utility node and five Riak nodes.

## IPs

```
10.0.0.110	utility.pi 	b8:27:eb:fc:c5:10
10.0.0.111	riak1.pi 	b8:27:eb:a6:0d:2f
10.0.0.112	riak2.pi 	b8:27:eb:db:53:2e
10.0.0.113	riak3.pi 	b8:27:eb:9e:ea:52
10.0.0.114	riak4.pi 	b8:27:eb:d3:24:30
10.0.0.115	riak5.pi 	b8:27:eb:e4:bf:27
```

## Logins

If you edit your own hosts file you can use the above hostnames; otherwise you need to use IPs.

* Linux login: basho demo-cluster (to be replaced by keys in repo)
* HA Proxy Status: http://10.0.0.110:8888 admin admin
* Graphite: http://10.0.0.110 root password
* Grafana: http://10.0.0.110:3000 admin admin
