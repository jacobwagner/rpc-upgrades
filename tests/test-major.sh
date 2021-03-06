#!/usr/bin/env bash

# Copyright 2018, Rackspace US, Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

export RE_JOB_UPGRADE_TO=${RE_JOB_UPGRADE_TO:-'newton'}

pushd /opt/rpc-openstack
  git clean -df
  git reset --hard HEAD
  rm -rf openstack-ansible
  git checkout ${RE_JOB_UPGRADE_TO}
  (git submodule init && git submodule update) || true
popd
pushd /opt/rpc-openstack/openstack-ansible
  export TERM=linux
  export I_REALLY_KNOW_WHAT_I_AM_DOING=true
  # remove all ansible_ssh_host entries
  sed -i '/ansible_host/d' /etc/openstack_deploy/user*.yml
  # upgrade looks for user_variables so drop one in place for upgrade
  if [[ ! -f /etc/openstack_deploy/user_variables.yml ]]; then
     echo "---" > /etc/openstack_deploy/user_variables.yml
     echo "default_bind_mount_logs: False" >> /etc/openstack_deploy/user_variables.yml
  elif [[ -f /etc/openstack_deploy/user_variables.yml ]]; then
     echo "default_bind_mount_logs: False" >> /etc/openstack_deploy/user_variables.yml
  fi
  echo "YES" | bash scripts/run-upgrade.sh
popd
