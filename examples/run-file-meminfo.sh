#!/bin/bash

set -e
set -u
set -o pipefail

# get the directory the script exists in
__dir=$(cd $(dirname ${BASH_SOURCE[0]})/../scripts/docker/large && pwd)
__proj_dir="$(cd $(dirname ${BASH_SOURCE[0]})/../ && pwd)"
__proj_name="$(basename $__proj_dir)"

export PLUGIN_SRC="${__proj_dir}"

# verifies dependencies
. "${__proj_dir}/examples/.setup.sh"

# downloads plugins, starts snap, load plugins and start a task
cd "${__proj_dir}/examples" && docker-compose exec main bash -c "PLUGIN_PATH=/etc/snap/plugins /${__proj_name}/examples/file-meminfo.sh && printf \"\n\nhint: type 'snaptel task list'\ntype 'exit' when your done\n\n\" && bash"