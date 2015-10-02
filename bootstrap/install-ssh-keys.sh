#!/bin/sh

SSH_DIR=/home/basho/.ssh
PUB_KEY=/home/basho/riak-pi-cluster/bootstrap/demo_cluster_id.pub

mkdir $SSH_DIR && chmod 700 $SSH_DIR
cat $PUB_KEY | tee $SSH_DIR/authorized_keys && chmod 600 $SSH_DIR/authorized_keys
