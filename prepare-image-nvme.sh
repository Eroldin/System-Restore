#!/bin/bash

EFIPARTITION="$(blkid -s UUID -o value /dev/nvme0n1p1)"
CRYPTBOOT="$(blkid -s UUID -o value /dev/nvme0n1p2)"
CRYPTLVM="$(blkid -s UUID -o value /dev/nvme0n1p5)"
CRYPTKEY="$(blkid -s PARTUUID -o value /dev/sda2)"
apt update; apt install build-essential git libssl-dev -y; apt clean; apt autoclean
install -dvm755 "/etc/skel/.config/dconf"
install -dvm755 "/etc/skel/.config/Code Industry"
install -dvm755 "/recovery/os/target"
install -vm644 "/home/oem/.config/dconf/user" "/etc/skel/.config/dconf/user"
install -vm644 "/home/oem/.config/Code Industry/Master PDF Editor.conf" "/etc/skel/.config/Code Industry"
install -vm700 "/media/sf_Linux/System-Restore/autostart.sh" "/tmp"; sed -i "s/UUID1/$EFIPARTITION/" /tmp/autostart.sh; sed -i "s/UUID2/$CRYPTBOOT/" /tmp/autostart.sh; sed -i "s/UUID3/$CRYPTLVM/" /tmp/autostart.sh; sed -i "s/PARTUUID/$CRYPTKEY/" /tmp/autostart.sh
/media/sf_Linux/System-Restore/obash -cr /tmp/autostart.sh -o /recovery/os/opt/.autostart
chmod 700 /recovery/os/opt/.autostart
install -vm700 "/media/sf_Linux/System-Restore/update-grub.sh" "/opt/.update-grub.sh"
install -vm755 "/media/sf_Linux/System-Restore/afterimage.service" "/etc/systemd/system/"
systemctl enable afterimage.service
echo -e "\nFSTAB ==> RO !!!"
