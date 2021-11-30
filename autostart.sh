#!/bin/bash

trap '' 2 9 20
EFIPARTITION="/dev/disk/by-uuid/UUID1"
CRYPTBOOT="/dev/disk/by-uuid/UUID2"
CRYPTLVM="/dev/disk/by-uuid/UUID3"
CRYPTKEY="/dev/disk/by-partuuid/PARTUUID"

echo -e "\nUnlocking disks..."
cryptsetup open --allow-discards -d "$CRYPTKEY" "$CRYPTBOOT" cryptboot
RESULT=$?
if [ $RESULT -eq 0 ]; then
	:
else
	echo -e "\nFailed to unlock the disks, rebooting the system..."; sleep 2; reboot
fi
cryptsetup open --allow-discards -d "$CRYPTKEY" "$CRYPTLVM" cryptlvm
RESULT=$?
if [ $RESULT -eq 0 ]; then
	:
else
	echo -e "\nFailed to unlock the disks, rebooting the system..."; sleep 2; reboot
fi
sleep 2
echo -e "\nTurning on the swap partition..."
swapon /dev/mapper/crypt-swap
sleep 2
echo -e "\nStarting system restore...\n"
sleep 2
openssl enc -d -kfile "$CRYPTKEY" -in /images/boot.gz.img | unpigz -c | partclone.ext4 -r -O /dev/mapper/cryptboot
openssl enc -d -kfile "$CRYPTKEY" -in /images/root.gz.img | unpigz -c | partclone.ext4 -r -O /dev/mapper/crypt-root
openssl enc -d -kfile "$CRYPTKEY" -in /images/home.gz.img | unpigz -c | partclone.ext4 -r -O /dev/mapper/crypt-home
echo -e "\nUpdating the initramfs and the grub boot loader...\n"
sleep 2
mount /dev/mapper/crypt-root /target
mount /dev/mapper/cryptboot /target/boot
mount /dev/mapper/crypt-home /target/home
mount "$EFIPARTITION" /target/boot/efi
arch-chroot /target bash -c "update-initramfs -k all -c; grub-install; update-grub"
umount -R /target
echo -e "\nStarting the user configuration after reboot...\n"
sleep 2
reboot
trap 2 9 20
