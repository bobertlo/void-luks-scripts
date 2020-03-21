# Void Luks Scripts

This repo contains scripts to automate the installation of Void Linux with
encrypted disks. This is based on the full disk encrypytion (encrypted boot)
page of the old Void Linux wiki, found here:

<https://wiki.voidlinux.org/Full_Disk_Encryption_w/Encrypted_Boot>

## How the scripts work

There are three files to be aware of:

- `config`: stores variables for both scripts. Make sure these are correct.
- `fde.sh`: creates the encrypted partition, volumes, and filesystems, installs
   the base system packages, and then calls the next stage script inside a
   chroot.
- `fde-chroot.sh`: this is the second stage script that executes inside the
   chroot. It sets system options and configures grub.

Please read all the scripts before running them! Changes can be made as you see
fit. Configuration variables are stored in `config` and sourced by both scripts.

## Running the scripts

1. Copy the scripts inside a live install environemnt and make sure the settings
   are correct.
2. Create the desired target partition on disk.
3. Run `fde.sh`
