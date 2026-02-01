#!/bin/sh

PATH=/sbin:/bin:/usr/sbin:/usr/bin

mkdir -p /proc
mkdir -p /sys
mkdir -p /dev
mkdir -p /mnt

mount -t proc proc /proc
mount -t sysfs sysfs /sys
mount -t devtmpfs devtmpfs /dev
mount /dev/mmcblk0p1 /mnt || {
    echo "ERROR: Failed to mount boot partition!"
    exec /bin/sh
}
echo "1. mount is okay"

echo "========================================="
echo "from the init script !"
echo "========================================="
#sleep 5
#exec sh

#################################################################################################################################
key_path="/mnt/pass.txt"
encrypted_slot="slot_a_crypt"
mapper_slot="/dev/mapper/slot_a_crypt"
target_block="/dev/mmcblk0p2"
#################################################################################################################################

__encrypt_partitions()
{
    echo "2. encrypting paritions ......."
    cryptsetup luksClose "$encrypted_slot" 2>/dev/null || true
    dd if="$target_block" of=/mnt/rootfs_backup.img bs=4M status=progress 
    cryptsetup luksFormat --key-size 512 "$target_block" --key-file "$key_path" 
    cryptsetup luksOpen "$target_block" "$encrypted_slot" --key-file "$key_path" 
    mkfs.ext4 /dev/mapper/"$encrypted_slot" 
    mkdir -p /tmp/rootfs_old
    umount /tmp/rootfs_old 2>/dev/null || true
    mount /mnt/rootfs_backup.img /tmp/rootfs_old 

    echo "[+] mount encrypted fs"
    mkdir -p /tmp/rootfs_encrypted
    umount /dev/mapper/"$encrypted_slot" /tmp/rootfs_encrypted 2>/dev/null

    mount /dev/mapper/slot_a_crypt /tmp/rootfs_encrypted

    echo "[+] copying rootfs from decrypted to encrypted partition"
    rsync -avh --progress /tmp/rootfs_old/ /tmp/rootfs_encrypted/ 

    sync
    rm -f /mnt/rootfs_backup.img

    # For safety    
    umount /tmp/rootfs_encrypted/ || true
    umount /tmp/rootfs_old/ || true
    #  cryptsetup luksClose "$encrypted_slot" // no need to close if we are going using it later in decryption.
    echo "=======>encryption done<======="
}

__isEncrypted()
{
    cryptsetup isLuks /dev/mmcblk0p2
    return $?
}
__mount_rootfs()
{
    echo "3. mount roofs"
    mkdir -p /rootfs

    mount "$mapper_slot" /rootfs

    if [ ! -d /rootfs/sbin ]; then
        echo "from initramfs Failed to mount root filesystem!"
        exec /bin/sh
    fi

    echo "4. roofs is mounted"
    umount /proc
    umount /sys
    umount /dev
    umount /mnt

    echo "5. switch root"
    # give the hand to the new rootfs
    exec switch_root /rootfs /sbin/init
}

#### Main
echo "encryption ..."
__encrypt_partitions
#__decrypt_partitions
echo "mounting rootfs"
__mount_rootfs