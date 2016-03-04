#!/bin/bash

## FUNCTIONS A-Z

install_jupyter () {
  # todo: check permissions are correct for this set of commands
  apt-get install build-essential libffi-dev libssl-dev python-setuptools python-dev python-pip --yes
  pip install --upgrade pip
  pip install jupyter
  pip install riak

}

## SCRIPT

script_path="$(cd $(dirname ${0}) && pwd)"
source "${script_path}/../.riak-pi-include"

run_as_superuser
install_jupyter
