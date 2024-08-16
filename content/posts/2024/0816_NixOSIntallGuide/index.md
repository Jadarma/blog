---
title: 'Installing NixOS with Flakes and LVM on LUKS'
description: 'A step-by-step guide to quickly installing NixOS with flakes and full-disk encryption.'
date: 2024-08-16
category: 'technology'
tags: [ 'nix', 'tutorial' ]
---

Do you want to set up your machine with NixOS?
Are you fond of using full-disk encryption as well?
Do you want to be spoon-fed best practices first and learn from them later?
Then this is the guide for you!

<!--more-->

# Before we Start

If you are new to NixOS, or dare I say Linux in general, your best bet is to dip your toes into a virtual machine first.
It will teach you the ins and outs, and provide a cushion over your head as you bang it against the walls of this rabbit
hole.
In that case, a simple _"next, next, next"_ directly from the graphical installer is all you really need, thanks for
reading!

But, since you're still here, it means you want to do it on bare metal, and you just want to get the initial install
over with so that you can go back to configuring your setup.

I wrote this guide mostly for myself, because I don't like remembering things, so I'd rather document them;
and if it helps others learn too, all the better!
This is actually a more generalized guide derived from my notes from
[my personal dotfiles](https://github.com/Jadarma/nixfiles).

This article assumes you already are familiar with the basic concepts of [NixOS](https://nixos.org/) and
[flakes](https://nixos.wiki/wiki/Flakes), this is not so much an explanation of the thing, but rather a step-by-step
guide to doing the thing.

The internet is fraught with information, should you need to look it up!

## So, what are we configuring exactly?

- A _"bare-bone essentials"_ NixOS install, as close to the system the install ISO would give you;
- Full disk encryption using LVM on LUKS; _(so you can let your laptop get stolen without worries \s)_
- Use flakes right out the gate to make it easy to version control your configuration.

## Be Mindful of The Placeholders

Because this guide contains commands and config references, ***some values are placeholders*** to make things easier.
Here they are:

- The main installation drive is `/dev/sdx`.
- The hostname of the new machine is `nixos`.
- The main user is `me`.
- The names for the LUKS and LVM mapped devices is `cryptroot` and `lvmroot`, but you can leave these as-is, they just
  need _a_ name.

## Let's Get Started

Prepare a USB with the latest [NixOS ISO](https://nixos.org/download) for your architecture.
The recommended graphical installer will do just fine, even if we'll be needing just a CLI.

Boot into it, connect to the internet if you're on a laptop, and open a terminal.

## Disk Formatting

For sake of simplicity, I'm assuming you will have a single system drive to install NixOS on.
If you have other drives you wish to use, you can handle those now as well, but if they are only for extra storage,
and will not hold any system partitions, then you can always configure them later.

I shouldn't need to remind you this is going to **wipe your data** so make your backups, and be careful not to run these
commands on the wrong disk!

### Drive Partitioning

We will be using full-disk encryption, so we only need two partitions: one for booting, and the rest of the drive.
We'll use `gdisk` for this.

```shell
sudo gdisk /dev/sdx
```

Then do the following:

- View help. (`?`)
- Create a new GPT. (`o`)
- Create a new EFI partition. (`n <default> <default> +1G ef00`)
- Create a new LVM partition for the rest of the drive. (`n <default> <default> <default> 8e00`)
- Save the changes and exit. (`w`)

Running `sudo lsblk` again should show the two partitions as `/dev/sdx1` and `/dev/sdx2`.

### LUKS Encryption

We can now enable full-disk encryption with LUKS via a master password.
There are alternatives, such as dummy USB headers or YubiKeys but let's keep it simple here.

Forgetting the password for your LUKS container results in a permanent loss of access to the drive's contents.
Store it in a safe place, like a password manager!

```shell
sudo cryptsetup -v -y \
    -c aes-xts-plain64 -s 512 -h sha512 -i 2000 --use-random \
    --label=NIXOS_LUKS luksFormat --type luks2 /dev/sdx2
```

An explanation of above options:

- `-v`: Verbose, increases output for debugging in case something goes wrong.
- `-y`: Ask for the password interactively, twice, and ensure their match before proceeding.
- `-c`: Specifies the cypher, in this case `aes-xts-plain64` is also the default for the LUKS2 format.
- `-s`: Specifies the key size used by the cypher.
- `-h`: Specifies the hashing algorith used, `sha256` by default.
- `-i`: Milliseconds to spend processing the passphrase, `2000` by default. Longer is more secure but less convenient.
- `--use-random`: Specifies the more secure RNG source.
- `--label`: Adds a label to the partition so we can reference it easily in configs.
- `luksFormat`: Operation mode that encrypts a partition and sets a passphrase.
- `--type`: Specify the LUKS type to use.
- `/dev/sdx2`: The partition you wish to encrypt.

You can inspect the LUKS header to check everything OK with `sudo cryptsetup luksDump /dev/sdx2`.

It is also a good practice to back it up.
Create a copy with `sudo cryptsetup luksHeaderBackup --header-backup-file /a/path/header.img /dev/sdx2`.
Do so when it is convenient later.

Open the LUKS container so that we can use it.

```shell
sudo cryptsetup open --type luks /dev/sdx2 cryptroot
```

Check the mapped device exists:

```shell
ls /dev/mapper/cryptroot
```

### LVM Partitioning

Create a physical volume, and a volume group within it.

```shell
sudo pvcreate         /dev/mapper/cryptroot
sudo vgcreate lvmroot /dev/mapper/cryptroot
```

Create the logical partitions you want to use, it's up to you how you size them.
I recommend you set aside at least 128G for your root partition to have dedicated breathing room for the `/nix/store`,
match your RAM for the swap, and leave the rest for your home partition.
If you have lots of RAM, or don't plan on using hibernation, you can skip the swap partition entirely, as you
can always create an arbitrary swapfile when in a pinch.

```shell
sudo lvcreate -L16G       lvmroot -n swap
sudo lvcreate -L128G      lvmroot -n root
sudo lvcreate -l 100%FREE lvmroot -n home
```

### Filesystem Formatting

All the partitions are in place, we can now format them with the appropriate filesystems and label them for easy
reference in the configuration.

**NOTE:** Labels should be short! Maximum of 11 bytes for the boot, and 16 bytes for the rest, keep that in mind if you
want to name them differently.

```shell
sudo mkfs.fat  -n NIXOS_BOOT -F32 /dev/sdx1
sudo mkfs.ext4 -L NIXOS_ROOT      /dev/mapper/lvmroot-root
sudo mkfs.ext4 -L NIXOS_HOME      /dev/mapper/lvmroot-home
sudo mkswap    -L NIXOS_SWAP      /dev/mapper/lvmroot-swap
```

### Mounting the Partitions

Mount the partitions inside `/mnt`.

```shell
sudo mount /dev/disk/by-label/NIXOS_ROOT /mnt
sudo mkdir /mnt/boot
sudo mkdir /mnt/home
sudo mount -o umask=0077 /dev/disk/by-label/NIXOS_BOOT /mnt/boot
sudo mount /dev/disk/by-label/NIXOS_HOME /mnt/home
sudo swapon -L NIXOS_SWAP
```

This is how your drive should be partitioned:

```text
# Output of `sudo lsblk -o name,type,mountpoints /dev/sdx`:
NAME               TYPE  MOUNTPOINTS
sdx                disk
├─sdx1             part  /mnt/boot
└─sdx2             part
  └─cryptroot      crypt
    ├─lvmroot-swap lvm   [SWAP]
    ├─lvmroot-root lvm   /mnt
    └─lvmroot-home lvm   /mnt/home
```

## NixOS Bootstrapping

We can now start setting up the fresh-install of NixOS.

### Minimal Configuration

Generate a NixOS config.

```shell
sudo nixos-generate-config --root /mnt
```

This gives us a starting point to edit from, but it's not correct out of the box, especially because we're using LUKS.
So now let's edit these files manually.

For reference, I will provide a working example from my test run on an old laptop, making note of the things added or
changed noted by the `# <--` comments.
You shouldn't touch the things not mentioned _(yet)_.

In `/mnt/etc/nixos/hardware-configuration.nix`, configure the following:

- Add the `cryptd` kernel module for LUKS.
- Define the primary LUKS device.
- Update the filesystem devices to `/dev/disk/by-label` for convenience.
- Enable firmware updates _(optional, but recommended)_.

For reference:

```nix
{ config, lib, pkgs, modulesPath, ... }:
{
  imports =
    [ (modulesPath + "/installer/scan/not-detected.nix")
    ];
  
  boot.initrd.availableKernelModules = [ "xhci_pci" "ehci_pci" "ahci" "usb_storage" "sd_mod" "rtsx_pci_sdmmc" ];
  boot.initrd.kernelModules = [ "dm-snapshot" "cryptd" ]; # <--
  boot.initrd.luks.devices."cryptroot".device = "/dev/disk/by-label/NIXOS_LUKS"; # <--
  boot.kernelModules = [ "kvm-intel" ];
  boot.extraModulePackages = [ ];
  
  fileSystems."/" =
    { device = "/dev/disk/by-label/NIXOS_ROOT"; # <--
      fsType = "ext4";
    };
    
  fileSystems."/boot" =
    { device = "/dev/disk/by-label/NIXOS_BOOT"; # <--
      fsType = "vfat";
      options = [ "fmask=0077" "dmask=0077" ];
    };
    
  fileSystems."/home" =
    { device = "/dev/disk/by-label/NIXOS_HOME"; # <--
      fsType = "ext4";
    };
    
  swapDevices =
    [ { device = "/dev/disk/by-label/NIXOS_SWAP"; } # <--
    ];
    
  networking.useDHCP = lib.mkDefault true;
  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  hardware.enableAllFirmware = true; # <--
  hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
}
```

In `/mnt/etc/nixos/configuration.nix`, configure the following:

- Enable flakes.
- Enable networking and set a hostname.
- Create a user for yourself.
- Add `neovim` and `git` to the systemPackages for convenience.
- Allow unfree packages _(optional, recommended)_.

There are also many commented-out suggestions, if you want you can take your time and enable them now.

For reference:

```nix
{ config, lib, pkgs, ... }:
{
  imports =
    [ ./hardware-configuration.nix
    ];
  
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  
  networking.hostname = "nixos"; # <--
  networking.networkManager.enable = true; # <--
  
  services.xserver.enable = true;
  services.xserver.displayManager.gdm.enable = true;
  services.xserver.desktopManager.gnome.enable = true;

  users.users.me = { # <--
    isNormalUser = true;
    createHome = true;
    extraGroups = [ "networkmanager" "wheel" ]; # <--
  };
  
  environment.systemPackages = with pkgs; [ git neovim ]; # <--
  
  nix.settings.experimental-features = [ "nix-command" "flakes" ]; # <--
  nixpkgs.config.allowUnfree = true; # <--
  system.stateVersion = "24.05";
}
```

This should be enough for a first install, but we also want to make this into a flake.

Create `/mnt/etc/nixos/flake.nix` with the following contents:

```nix
{
  description = "My NixOS Config";
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.05";
  };
  outputs = inputs@{ self, nixpkgs, ...}: {
    nixosConfigurations.nixos = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [ ./configuration.nix ];
    };
  };
}
```

Note that:
- The `nixos` in `nixosConfigurations.nixos` is the hostname you defined in the configuration file.
- `system` should be the same as the `nixpkgs.hostPlatform` in your hardware configuration file.
- The `nixpkgs.url` should be either `nixos-unstable` for the bleeding edge or the same as your `system.stateVersion`.

Now we have a flake, but we need to generate a lockfile for it.
Since we run this command from the context of the installation ISO, we need to pass the experimental flags ourselves.

```shell
cd /mnt/etc/nixos
sudo nix --extra-experimental-features nix-command --extra-experimental-features flakes flake update
cd
```

Let's install it!
We'll also disable root login because we don't need it, and tell it to run our flake configs.
The `#nixos` is, again, the hostname, basically the entry of the `outputs.nixosConfigurations` in our flake file.

Be patient, this might take a while:

```shell
sudo nixos-install --root /mnt --no-root-passwd --flake /mnt/etc/nixos#nixos
```

Now we should set a password for our user:

```shell
sudo nixos-enter --root /mnt -c 'passwd me'
```

We're done with the ISO, let's safely unmount everything and reboot.

```shell
sudo umount -R /mnt
sudo swapoff -L NIXOS_SWAP
sudo vgchange -a n lvmroot
sudo cryptsetup close /dev/mapper/cryptroot
reboot
```

## What now?

The first step before going on your ricing adventures is to turn this into a Git repo!
This enables many conveniences, most notably that you can keep it in your user dir rather than the root 
protected `/etc/nixos`.

```shell
mkdir ~/repo/nixfiles
cd ~/repo/nixfiles
cp /etc/nixos/* .
git init
git commit -am "Initial commit."
```

You can now even get rid of the old ones, you don't need them anymore.

```shell
sudo rm /etc/nixos/*
```

You can make all your changes in the Git repo, publish them on GitHub, and always restore from them.
There are three main commands you should remember:

- `nix flake update` will update your `flake.lock` to the newest versions of your flake inputs.
- `sudo nixos-rebuild test --flake .#` will make the changes to your system but only until next boot.
  Use this for trial and error.
- `sudo nixos-rebuild switch --flake .#` will apply the changes and create a new generation for your boot entries.
- `sudo nix-collect-garbage --delete-old` _(or `--delete-older-than 30d`)_ helps you get rid of old generations and 
  leftover `/nix/store` paths.

Also, note that the flake will ignore untracked git files!
If you're having problems activating it, that's one of the main _oopsies_.

A good place to start is integrating
[HomeManager](https://github.com/nix-community/home-manager) and 
[NixOS Hardware](https://github.com/NixOS/nixos-hardware)
into your flakes, but I don't want to get into details because this article would get too long!

## Bonus: Future Re-Installs.

NixOS doesn't really need to be reinstalled, but let's say you just wanna do spring cleaning, or your drive failed and
you replaced it with a new one, do you start over?
**NO!**

Since you have your config use labels instead of UUIDs, you can follow just the formatting portion, and instead of creating
and editing the configs, apply them _directly from Git_ using the `nixos-install --flake` command!

For reference, here is a recap of how quick and easy the re-installation would be, from start to finnish:

```shell
# Paritioning
sudo gdisk /dev/sdx
# Luks
sudo cryptsetup -v -y -c aes-xts-plain64 -s 512 -h sha512 -i 4000 --use-random --label=NIXOS_LUKS luksFormat --type luks2 /dev/sdx2
sudo cryptsetup open --type luks /dev/sdx2 cryptroot
# LVM
sudo pvcreate         /dev/mapper/cryptroot
sudo vgcreate lvmroot /dev/mapper/cryptroot
sudo lvcreate -L16G       lvmroot -n swap
sudo lvcreate -L128G      lvmroot -n root
sudo lvcreate -l 100%FREE lvmroot -n home
# Filesystems
sudo mkfs.fat  -n NIXOS_BOOT -F32 /dev/sdx1
sudo mkfs.ext4 -L NIXOS_ROOT      /dev/mapper/lvmroot-root
sudo mkfs.ext4 -L NIXOS_HOME      /dev/mapper/lvmroot-home
sudo mkswap    -L NIXOS_SWAP      /dev/mapper/lvmroot-swap
# Mounting
sudo mount /dev/disk/by-label/NIXOS_ROOT /mnt
sudo mkdir /mnt/boot
sudo mkdir /mnt/home
sudo mount -o umask=0077 /dev/disk/by-label/NIXOS_BOOT /mnt/boot
sudo mount /dev/disk/by-label/NIXOS_HOME /mnt/home
sudo swapon -L NIXOS_SWAP
# Installing NixOS From a Flake
sudo nixos-install --root /mnt --no-root-passwd --flake github:me/nixfiles#nixos
sudo nixos-enter --root /mnt -c 'passwd me'
# Unmounting
sudo umount -R /mnt
sudo swapoff -L NIXOS_SWAP
sudo vgchange -a n lvmroot
sudo cryptsetup close /dev/mapper/cryptroot
# Done!
reboot
```

## Conclusion

This just scratches the surface of what NixOS can do, and I purposefully left things as minimal as possible to not
_"opinionate"_ you to death.

I hope you found it useful.
Cheers! ❄️🍻❄️
