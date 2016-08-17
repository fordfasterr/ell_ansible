#!/bin/bash

# Install NX
mkdir -v /ellucian
/bin/mount -v 10.52.4.35:/exports /ellucian
/bin/rpm -ihv /ellucian/software/nx*
/bin/umount -v /ellucian
rm -rf /ellucian
