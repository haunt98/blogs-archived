# Install Arch Linux

Install Arch Linux is thing I always want to do for my laptop/PC since I had my laptop in ninth grade.

This is not a guide for everyone, this is just save for myself in a future and for anyone who want to walk in my shoes.

## [Installation guide](https://wiki.archlinux.org/index.php/Installation_guide)

### Pre-installation

Check disks carefully:

```sh
lsblk
```

[USB flash installation medium](https://wiki.archlinux.org/index.php/USB_flash_installation_medium)

#### Verify the boot mode

Check UEFI mode:

```sh
ls /sys/firmware/efi/efivars
```

#### Connect to the internet

For wifi, use [iwd](https://wiki.archlinux.org/index.php/Iwd).

#### Partition the disks

[GPT fdisk](https://wiki.archlinux.org/index.php/GPT_fdisk):

```sh
cgdisk /dev/sdx
```

[Partition scheme](https://wiki.archlinux.org/index.php/Partitioning#Partition_scheme)

UEFI/GPT layout:

| Mount point | Partition                             | Partition type                 | Suggested size |
| ----------- | ------------------------------------- | ------------------------------ | -------------- |
| `/mnt/efi`  | `/dev/efi_system_partition`           | EFI System Partition           | 512 MiB        |
| `/mnt/boot` | `/dev/extended_boot_loader_partition` | Extended Boot Loader Partition | 1 GiB          |
| `/mnt`      | `/dev/root_partition`                 | Root Partition                 |                |

BIOS/GPT layout:

| Mount point | Partition             | Partition type      | Suggested size |
| ----------- | --------------------- | ------------------- | -------------- |
|             |                       | BIOS boot partition | 1 MiB          |
| `/mnt`      | `/dev/root_partition` | Root Partition      |                |

LVM:

```sh
# Create physical volumes
pvcreate /dev/sdaX

# Create volume groups
vgcreate RootGroup /dev/sdaX /dev/sdaY

# Create logical volumes
lvcreate -l +100%FREE RootGroup -n rootvol
```

Format:

```sh
# efi
mkfs.fat -F32 /dev/efi_system_partition

# boot
mkfs.fat -F32 /dev/extended_boot_loader_partition

# root
mkfs.ext4 -L ROOT /dev/root_partition

# root with btrfs
mkfs.btrfs -L ROOT /dev/root_partition

# root on lvm
mkfs.ext4 /dev/RootGroup/rootvol
```

Mount:

```sh
# root
mount /dev/root_partition /mnt

# root with btrfs
mount -o compress=zstd /dev/root_partition /mnt

# root on lvm
mount /dev/RootGroup/rootvol /mnt

# efi
mount --mkdir /dev/efi_system_partition /mnt/efi

# boot
mount --mkdir /dev/extended_boot_loader_partition /mnt/boot
```

### Installation

```sh
pacstrap -K /mnt base linux linux-firmware

# AMD
pacstrap -K /mnt amd-ucode

# Intel
pacstrap -K /mnt intel-ucode

# Btrfs
pacstrap -K /mnt btrfs-progs

# LVM
pacstrap -K /mnt lvm2

# Text editor
pacstrap -K /mnt neovim
```

### Configure

#### [fstab](https://wiki.archlinux.org/index.php/Fstab)

```sh
genfstab -U /mnt >> /mnt/etc/fstab
```

#### Chroot

```sh
arch-chroot /mnt
```

#### Time zone

```sh
ln -sf /usr/share/zoneinfo/Region/City /etc/localtime

hwclock --systohc
```

#### Localization:

Edit `/etc/locale.gen`:

```txt
# Uncomment en_US.UTF-8 UTF-8
```

Generate locales:

```sh
locale-gen
```

Edit `/etc/locale.conf`:

```txt
LANG=en_US.UTF-8
```

#### Network configuration

Edit `/etc/hostname`:

```txt
myhostname
```

#### Initramfs

Edit `/etc/mkinitcpio.conf`:

```txt
# LVM
# https://wiki.archlinux.org/title/Install_Arch_Linux_on_LVM#Adding_mkinitcpio_hooks
HOOKS=(base udev ... block lvm2 filesystems)

# https://wiki.archlinux.org/title/mkinitcpio#Common_hooks
# Replace udev with systemd
```

```sh
mkinitcpio -P
```

#### Root password

```sh
passwd
```

#### Addition

```sh
# NetworkManager
pacman -Syu networkmanager
systemctl enable NetworkManager.service

# Bluetooth
pacman -Syu bluez
systemctl enable bluetooth.service

# Clock
timedatectl set-ntp true
```

#### Boot loader

[systemd-boot](Applications/System/systemd-boot.md)

[GRUB](https://wiki.archlinux.org/index.php/GRUB)

## [General recommendations](https://wiki.archlinux.org/index.php/General_recommendations)

Always remember to check **dependencies** when install packages.

### System administration

[Sudo](https://wiki.archlinux.org/index.php/sudo):

```sh
pacman -Syu sudo

EDITOR=nvim visudo
# Uncomment group wheel

# Add user if don't want to use systemd-homed
useradd -m -G wheel -c "The Joker" joker

# Or using zsh
useradd -m -G wheel -s /usr/bin/zsh -c "The Joker" joker

# Set password
passwd joker
```

[systemd-homed (WIP)](https://wiki.archlinux.org/index.php/Systemd-homed):

```sh
systemctl enable systemd-homed.service

homectl create joker --real-name="The Joker" --member-of=wheel

# Using zsh
homectl update joker --shell=/usr/bin/zsh
```

**Note**:
Can not run `homectl` when install Arch Linux.
Should run on the first boot.

### Desktop Environment

Install [Xorg](https://wiki.archlinux.org/index.php/Xorg):

```sh
pacman -Syu xorg-server
```

#### [GNOME](https://wiki.archlinux.org/index.php/GNOME)

```sh
pacman -Syu gnome-shell \
	gnome-control-center gnome-system-monitor \
	gnome-tweaks gnome-backgrounds gnome-screenshot gnome-keyring gnome-logs \
	gnome-console gnome-text-editor \
	nautilus xdg-user-dirs-gtk file-roller evince eog

# Login manager
pacman -Syu gdm
systemctl enable gdm.service
```

#### [KDE (WIP)](https://wiki.archlinux.org/title/KDE)

```sh
pacman -Syu plasma-meta \
	kde-system-meta

# Login manager
pacman -Syu sddm
systemctl enable sddm.service
```

## [List of applications](https://wiki.archlinux.org/index.php/List_of_applications)

### [pacman](https://wiki.archlinux.org/index.php/pacman)

Uncomment in `/etc/pacman.conf`:

```txt
# Misc options
Color
ParallelDownloads
```

### [Pipewire (WIP)](https://wiki.archlinux.org/title/PipeWire)

```sh
pacman -Syu pipewire wireplumber \
	pipewire-alsa pipewire-pulse \
	gst-plugin-pipewire pipewire-v4l2
```

### [Flatpak (WIP)](https://wiki.archlinux.org/title/Flatpak)

```sh
pacman -Syu flatpak
```

## [Improving performance](https://wiki.archlinux.org/index.php/improving_performance)

https://wiki.archlinux.org/index.php/swap#Swap_file

https://wiki.archlinux.org/index.php/swap#Swappiness

https://wiki.archlinux.org/index.php/Systemd/Journal#Journal_size_limit

https://wiki.archlinux.org/index.php/Core_dump#Disabling_automatic_core_dumps

https://wiki.archlinux.org/index.php/Solid_state_drive#Periodic_TRIM

https://wiki.archlinux.org/index.php/Silent_boot

https://wiki.archlinux.org/title/Improving_performance#Watchdogs

https://wiki.archlinux.org/title/PRIME

## In the end

This guide is updated regularly I promise.
