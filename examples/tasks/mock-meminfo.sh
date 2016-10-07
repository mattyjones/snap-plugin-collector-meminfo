#!/bin/bash

set -e
set -u
set -o pipefail

# get the directory the script exists in
__dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# source the common bash script 
. "${__dir}/../../scripts/common.sh"

# ensure PLUGIN_PATH is set
TMPDIR=${TMPDIR:-"/tmp"}
PLUGIN_PATH=${PLUGIN_PATH:-"${TMPDIR}/snap/plugins"}
mkdir -p $PLUGIN_PATH

_info "downloading plugins"
(cd $PLUGIN_PATH && curl -sfLSO http://snap.ci.snap-telemetry.io/snap/master/latest/snap-plugin-publisher-mock-file && chmod 755 snap-plugin-publisher-mock-file)
(cd $PLUGIN_PATH && curl -sfLSO http://snap.ci.snap-telemetry.io/plugins/snap-plugin-collector-meminfo/latest_build/linux/x86_64/snap-plugin-collector-meminfo && chmod 755 snap-plugin-collector-meminfo)

SNAP_FLAG=0

# this block will wait check if snapctl and snapd are loaded before the plugins are loaded and the task is started
 for i in `seq 1 10`; do
            _info "try ${i}"
             if [[ -f /usr/local/bin/snapctl && -f /usr/local/bin/snapd ]];
                then
                    _info "loading plugins"
                    snapctl plugin load "${PLUGIN_PATH}/snap-plugin-publisher-mock-file"
                    snapctl plugin load "${PLUGIN_PATH}/snap-plugin-collector-meminfo"

                    _info "creating and starting a task"
                    snapctl task create -t "${__dir}/task-mem.json"

                    SNAP_FLAG=1

                    break
             fi 
        
        _info "snapctl and/or snapd are unavailable, sleeping for 5 seconds"
        sleep 5
done 


# check if snapctl/snapd have loaded
if [ $SNAP_FLAG -eq 0 ]
    then
     echo "Could not load snapctl or snapd"
     exit 1
fi
