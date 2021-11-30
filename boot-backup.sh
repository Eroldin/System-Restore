#!/bin/bash

mount -o remount,ro /boot
install -m0600 /dev/null /tmp/boot.tar
tar -C /boot --acls --xattrs --one-file-system -cf /tmp/boot.tar .
