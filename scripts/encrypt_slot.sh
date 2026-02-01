#!/bin/sh
# RUN THIS SCRIPT AS SUDO !
# RUN this after flashing sd card

# slot=$1

# if [[ $# -eq 0 ]]; then
#   echo "Usage sudo ./encrypt_slot.sh <slot>"
#   echo "Example: sudo ./encrypt_slot.sh mmcblk0p2"
#   exit 1
# fi

pass_path="../meta-aero-sw/recipes-core/images/files/pass.txt"
chmod 777 "$pass_path"

sudo umount /dev/mapper/slot_a_crypt 2>/dev/null || true
sudo cryptsetup erase slot_a_crypt 2>/dev/null || true
sudo cryptsetup luksClose slot_a_crypt 2>/dev/null || true

echo "[+] writing rootfs in backup"
sudo dd if=/dev/mmcblk0p2 of=rootfs_backup.img bs=4M status=progress 

echo "[+] encrypt slot"
sudo cryptsetup luksFormat --key-size 512 /dev/mmcblk0p2 --key-file "$pass_path"

echo "[+] open encrypted slot"
sudo cryptsetup luksOpen /dev/mmcblk0p2 slot_a_crypt --key-file "$pass_path"

sudo mkfs.ext4 /dev/mapper/slot_a_crypt

sudo mkdir -p /tmp/rootfs_old
echo "[+] mount backup"
sudo umount rootfs_backup.img /tmp/rootfs_old 2>/dev/null || true
sudo mount rootfs_backup.img /tmp/rootfs_old

echo "[+] mount encrypted fs"
sudo mkdir -p /tmp/rootfs_encrypted
sudo umount /dev/mapper/slot_a_crypt /tmp/rootfs_encrypted 2>/dev/null || true
sudo mount /dev/mapper/slot_a_crypt /tmp/rootfs_encrypted

echo "[+] copying rootfs from decrypted to encrypted partition"
sudo rsync -avh --progress /tmp/rootfs_old/ /tmp/rootfs_encrypted/

sync
rm -f rootfs_backup.img

echo "[+] closed encrypted slot"
# For safety    
sudo umount /tmp/rootfs_encrypted/
sudo umount /tmp/rootfs_old/
#sudo cryptsetup luksClose slot_a_crypt
