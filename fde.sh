. config

echo "### Initializing Luks Device: ${LUKSDEV}"
cryptsetup luksFormat --type luks1 ${LUKSDEV}

echo "### Mounting Luks Volume: ${LUKSNAME}"
cryptsetup luksOpen ${LUKSDEV} ${LUKSNAME}

echo "### Creating LVM Volume Group:"
vgcreate ${VGNAME} /dev/mapper/${LUKSNAME}

echo "### Creating logical volumes:"
lvcreate --name swap -L 2G ${VGNAME}
lvcreate --name root -l 100%FREE ${VGNAME}

echo "### Creating filesystems:"
mkfs.${FSTYPE} -L root /dev/${VGNAME}/root
mkswap /dev/${VGNAME}/swap

echo "### Preparing Chroot Filesystem:"

mount /dev/${VGNAME}/root /mnt
for dir in dev proc sys run; do
mkdir -p /mnt/$dir
mount --rbind /$dir /mnt/$dir
done

echo "### Installing base system packages:"
xbps-install -Sy -R ${MIRROR} -r /mnt base-system lvm2 cryptsetup grub

echo "### Running Chroot setup script..."
cp fde-chroot.sh /mnt/finish.sh
cp config /mnt/config
chroot /mnt /bin/sh /finish.sh

