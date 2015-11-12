#!/bin/bash

## SCRIPT

script_path="$(cd $(dirname ${0}) && pwd)"
source "${script_path}/../.riak-pi-include"

run_as_superuser
source "${script_path}/install-riak.sh"
source "${script_path}/install-collectd.sh"
