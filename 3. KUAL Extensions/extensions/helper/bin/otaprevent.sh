#!/bin/sh
mkdir -p /var/local/system
touch /var/local/system/SKIP_UPDATE_CHECK
rm -rf /mnt/us/update.bin.tmp.partial
mkdir -p /mnt/us/update.bin.tmp.partial
