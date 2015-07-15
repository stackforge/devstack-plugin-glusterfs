#!/bin/bash

# devstack/plugin.sh
# Triggers glusterfs specific functions to install and configure GlusterFS

# Dependencies:
#
# - ``functions`` file
# - ``GLUSTERFS_DATA_DIR`` and ``DATA_DIR`` must be defined

# ``stack.sh`` calls the entry points in this order:
#
# - install_glusterfs
# - configure_glusterfs_cinder & configure_privileged_user
# - start_glusterfs
# - stop_glusterfs
# - cleanup_glusterfs

# Defaults
# --------

# GLUSTERFS_PLUGIN_DIR contains the path to devstack-plugin-glusterfs/devstack directory
GLUSTERFS_PLUGIN_DIR=$(readlink -f $(dirname ${BASH_SOURCE[0]}))

# Set ``GLUSTERFS_DATA_DIR`` to the location of GlusterFS drives.
# Default is /var/lib/glusterfs.
GLUSTERFS_DATA_DIR=${GLUSTERFS_DATA_DIR:-/var/lib/glusterfs}
GLUSTERFS_DISK_IMAGE=${DATA_DIR}/cinder/glusterfs.img

# DevStack will create a loop-back disk formatted as XFS to store the
# GlusterFS data. Set ``GLUSTERFS_LOOPBACK_DISK_SIZE`` to the disk size in
# GB.
# Default is 4 gigabyte. But we can configure through localrc.
GLUSTERFS_LOOPBACK_DISK_SIZE=${GLUSTERFS_LOOPBACK_DISK_SIZE:-4G}

# Devstack will create GlusterFS shares to store Cinder volumes.
# Those shares can be configured by seting CINDER_GLUSTERFS_SHARES.
# By default CINDER_GLUSTERFS_SHARES="127.0.0.1:/vol1"
CINDER_GLUSTERFS_SHARES=${CINDER_GLUSTERFS_SHARES:-"127.0.0.1:/vol1"}

# Adding GlusterFS repo to CentOS / RHEL 7 platform.
GLUSTERFS_CENTOS_REPO=${GLUSTERFS_CENTOS_REPO:-"http://download.gluster.org/pub/gluster/glusterfs/LATEST/CentOS/glusterfs-epel.repo"}

# Initializing gluster specific functions
source $GLUSTERFS_PLUGIN_DIR/gluster-functions.sh

if [[ "$1" == "stack" && "$2" == "pre-install" ]]; then
    echo_summary "Installing GlusterFS"
    install_glusterfs
elif [[ "$1" == "stack" && "$2" == "post-config" ]]; then
        if is_service_enabled glance; then
            echo_summary "Configuring Glance for GlusterFS"
            configure_glance_backend_glusterfs
        fi
fi

if [[ "$1" == "unstack" ]]; then
    cleanup_glusterfs
    stop_glusterfs
fi

if [[ "$1" == "clean" ]]; then
    cleanup_glusterfs
fi

## Local variables:
## mode: shell-script
## End:
