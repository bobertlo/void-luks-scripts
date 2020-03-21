. /config

echo " # Setting filesystem permissions"
chown root:root /mnt
chmod 755 /

echo "## Assigning hostname"
echo ${VOIDHOSTNAME} >> /etc/hostname

echo "## Setting root password:"
passwd root

echo "## Configuring locale"
echo "LANG=en_US.UTF-8" > /etc/locale.conf
echo "en_US.UTF-8 UTF-8" >> /etc/default/libc-locales
xbps-reconfigure -f glibc-locales

echo "## Writing fstab"

cat >> /etc/fstab <<END
/dev/${VGNAME}/root	/	${FSTYPE}	defaults	0	0
/dev/${VGNAME}/swap	swap	swap	defaults	0	0
END

ROOTUUID="$(lsblk -o uuid -n /dev/${VGNAME}/root)"

echo "## Updating grub default config"
sed -i '/GRUB_CMDLINE_LINUX_DEFAULT=/s/"$/ rd.auto=1 cryptdevice=UUID='"$ROOTUUID"':lvm&/' /etc/default/grub
echo "GRUB_ENABLE_CRYPTODISK=y" >> /etc/default/grub

echo "## Creating volume.key"
dd bs=512 count=4 if=/dev/urandom of=/boot/volume.key
cryptsetup luksAddKey ${LUKSDEV} /boot/volume.key
chmod 000 /boot/volume.key
chmod -R g-rws,o-rws /boot

echo "## Writing cryptttab"
cat >> /etc/crypttab << END
${LUKSNAME}	${LUKSDEV}	/boot/volume.key	luks
END

echo "## Writing /etc/dracut.conf.d/10-crypt.conf"
cat >> /etc/dracut.conf.d/10-crypt.conf << END
install_items+=" /boot/volume.key /etc/crypttab "
END

echo "## Installing grub: ${GRUBDEV}"
grub-install ${GRUBDEV}

echo "## Reconfiguring Kernel: ${KERNELPKG}"
xbps-reconfigure -f ${KERNELPKG}
