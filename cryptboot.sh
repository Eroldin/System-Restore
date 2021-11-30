#!/bin/bash

echo 'KEYFILE_PATTERN="/etc/keys/*.bin"' >> /etc/cryptsetup-initramfs/conf-hook
echo 'UMASK=0077' >> /etc/initramfs-tools/initramfs.conf
update-initramfs -u -k all
