---
title: "Disaster Recovery Backups With Rsync"
description: "How I use rsync to keep a failsafe backup of my NAS for peace of mind."
date: 2026-09-03
thumbnail: thumb.webp
series: 'homelab'
category: 'technology'
tags: [ 'linux', 'tutorial' ]
---

A NAS with ZFS is both reliable and easy to back up, but to avoid surprises and for peace of mind, let's also set up a
conventional failsafe backup as well!

<!--more-->

# Scenario Recap & Rationale

In [a previous article]({{< ref "posts/2025/0829_ProjectMiniNAS" >}}), I went over setting up a TrueNAS box and also
touched on the basics of maintaining ZFS backups on external hard drives. 

So as of now, we have both redundancy for the live data and historical snapshots thanks to ZFS, as well as an offline
backup in the _(hopefully unlikely)_ event the RaidZ ever fails.

But this is still not _truly_ following the **3-2-1** mantra -- we technically have two copies, on a single medium.
I know that, traditionally, the medium refers to physical storage _(tape drives, BluRays, etc.)_, but I think in this
case, due to data volume, budget, and convenience, a better alternative is to have a separate _filesystem_ as our second
medium.

Why?
ZFS is cool, but it is highly specialized.
You cannot easily mount it on a non-NAS unless you are comfortable with the internals.
With sufficient skill issue, you might accidentally screw up the backup in the process of restoring it.
I would rather not rely on my future self to git gud.

Rather, let's bring back the traditional backup: a simple `ext4` partition.
With this we will actually have a **3-2-2** scheme: three copies, on two filesystems, and even better, two offline!

And what better standard tools to use than plain ol' `rsync` and `LUKS`?

# My Example Use Case

Before we get to the good part, I need to lay out more context...

Up until recently, my photos, documents, and code backups were a big, manually managed directory.
Although I have not written about it _(yet)_, I already started importing and labeling my data on self-hosted services.
I use [Immich](https://immich.app/) for my media, [Paperless-ngx](https://docs.paperless-ngx.com/) for documents, and
[Forgejo](https://forgejo.org/) for private projects and mirroring backups of my public GitHub repos. 

These awesome services store the files on disk in a customizable manner _(via StoragePaths)_, so it's not just a simple
data dump, it's actually semi-structured, which is great if I ever want direct access to it.

Since the point of these services is to allow for universal access to the data via web UIs and mobile apps, I don't
really _need_ to keep them duplicated in my original manual directory anymore;
but I also don't really want to have to back up the tons of extra container state, like databases and configs
_(you can if you want to, explained later)_.
Depending on how large your pools are, you might not want to have a non-ZFS backup of any but the most core data.

What I really want is a _disaster scenario_ backup.
I assume that if I ever need to use this backup, I am probably royally screwed and don't have my homelab setup anymore.
In that case, I am happy that I still have my core memory photos, and less concerned that they are stored by date and
not labeled.
You can think of it as the _"throw it in the backpack and flee the country"_ contingency, or whatever other excuse you
can come up with to convince yourself to buy yet another large external HDD.

# The Plan

Just like for the ZFS backups we plug an external HDD into the NAS and rawdog the backup via a couple of console
commands.
The plan is to connect the plain backup drive, execute some `rsync` commands, then dismount again.

Depending on what you want to back up, and the IO usage rate of the containers, you probably don't want to sync a live
dataset, as you might miss some writes or deletions in-between due to data races.
So does that mean we need to temporarily shut down the containers to execute the maintenance?
**NO!**

Remember that everything on our NAS is stored in ZFS, and we have snapshots!
In fact, we will make use of the very same snapshots we use for the incremental ZFS backups!
Every dataset has a hidden `.zfs` directory in its root.
Inside it, there's a virtual read-only filesystem with all the snapshots.
So, instead of reading from `/mnt/pool/dataset/my-stuff`, we can read from 
`/mnt/pool/dataset/.zfs/snapshot/snapshot_name/my-stuff` and see a working copy of the state of that dataset at the
time the snapshot was taken.
That means that just like our ZFS backup, there is _no downtime_ here either, since we are not touching any live data.

As an example, here is a list of paths of interest that I use _(trailing slashes are important!)_.
In my case each service has their own dataset, remember the `.zfs` directory exists _only_ on dataset roots!

```shell
"/mnt/pool/vault/.zfs/snapshot/$SNAPSHOT/"
"/mnt/pool/homelab/immich/.zfs/snapshot/$SNAPSHOT/images/library/"
"/mnt/pool/homelab/paperless/.zfs/snapshot/$SNAPSHOT/media/documents/originals/"
"/mnt/pool/homelab/forgejo/.zfs/snapshot/$SNAPSHOT/data/git/"
```

We don't want to write those out by hand every time, so we'll make a helper script for it.

An honorable mention: since now the images and docs are no longer part of the `vault` dataset, instead of only
accessing them from the service UIs, we could also mount those directories as _read-only_ shares.
That way, we can keep them accessible from the main PCs in case we need bulk programmatic access -- neat!

# Preparing The Drive

We use this one command to format and prepare a full-disk encryption on our external drive _(here, `/dev/sdx`)_ using
LUKS.

```shell
sudo cryptsetup luksFormat /dev/sdx \
  -v -y -h sha512 -i 4000 --label 'backup' 
```

LUKS has pretty sane defaults, I only slightly modify iterations and the hashing algorithm used.
An explanation of above options:

- `-v`: Verbose, increases output for debugging, just in case.
- `-y`: Ask for the password interactively, twice to verify.
- `-h`: Specifies the hashing algorithm used, `sha256` by default.
- `-i`: Milliseconds to spend processing the passphrase, `2000` by default.
- `--label`: Give the disk a human-friendly label.

Next, we open it:

```shell
sudo cryptsetup open /dev/sdx backup
```

This will create a mapping device, which we can format as a partition:

```shell
sudo mkfs.ext4 /dev/mapper/backup
```

The drive is now ready to use, in order to access it we also need to mount it:

```shell
sudo mount /dev/mapper/backup /mnt/backup
```

And afterward, safely dismounting:

```shell
sudo umount /mnt/backup
sudo cryptsetup close /dev/mapper/backup
```

From here on out, the four commands of `open`, `mount`, `umount`, and `close` are all that is needed to work
with the drive.
If you add a keyfile to the LUKS header, you can even automate this in `crypttab`.
But I'm fine with entering the password manually, helps keep it in my head.

# Script Automation

The backup drive will consist of a `.backup` directory with a script and a short `README` flash card in case I forget.
I also manually created the top-level directories for each dataset path I want synced, which will be the targets
_(i.e.: destinations)_ of the sync.

To use it, I just plug the drive in, type in the password, run the script, inspect the report, approve it, then unmount.
It's a manual process, but not too involved!

The heavy lifting will be done by a shell script:

1. Accept an existing snapshot name as input.
2. Manage a personalized _(i.e.: hardcoded)_ list of source and target directories to copy over.
3. Make some sanity checks.
4. Show a dry run summary for manual auditing and confirmation.
5. Perform the copy.
6. Persist the name of the snapshot in the `.backup` location to take note of when it took place.

Here is the full script in all its glory:

```bash
#!/usr/bin/env bash
set -euo pipefail

# Argument parsing, namely getting the snapshot name as the only argument.
if [[ $# -ne 1 ]]; then
    echo "Usage: $0 <snapshot>" >&2
    exit 1
fi

if [[ $1 = '--help' || $1 = '-h' ]]; then
    echo "Usage: $0 <snapshot>"
    exit 0
fi

# Show an error and exit. Call as error <reason> (<exit code>).
function error {
    echo "${1:-An unexpected error ocurred}" >&2
    exit "${2:-1}"
}

# Show a confirmation prompt, with a yes / no answer. Call as confirm <prompt>
function confirm {
    local reply
    read -r -s -n 1 -p "${1:-'Confirm?'} [Y/N]" reply
    printf '\n'
    [[ "$reply" =~ ^[Yy]$ ]]
}

# Determine backup sources and destinations.
# The destination is, by convention, the parent directory of the script, since the script is stored alongside the data.
BACKUP_TARGET=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )/.." &> /dev/null && pwd )
readonly BACKUP_TARGET
readonly BACKUP_SOURCE='root@nas:'
readonly SNAPSHOT="$1"

readonly BACKUP_SOURCE_VAULT="$BACKUP_SOURCE/mnt/pool/vault/.zfs/snapshot/$SNAPSHOT/"
readonly BACKUP_SOURCE_MEDIA="$BACKUP_SOURCE/mnt/pool/homelab/immich/.zfs/snapshot/$SNAPSHOT/images/library/"
readonly BACKUP_SOURCE_DOCS="$BACKUP_SOURCE/mnt/pool/homelab/paperless/.zfs/snapshot/$SNAPSHOT/media/documents/originals/"
readonly BACKUP_SOURCE_CODE="$BACKUP_SOURCE/mnt/pool/homelab/forgejo/.zfs/snapshot/$SNAPSHOT/data/git/"

readonly BACKUP_TARGET_VAULT="$BACKUP_TARGET/vault/"
readonly BACKUP_TARGET_MEDIA="$BACKUP_TARGET/media/"
readonly BACKUP_TARGET_DOCS="$BACKUP_TARGET/docs/"
readonly BACKUP_TARGET_CODE="$BACKUP_TARGET/code/"

declare -A BACKUP
BACKUP["$BACKUP_TARGET_VAULT"]="$BACKUP_SOURCE_VAULT"
BACKUP["$BACKUP_TARGET_MEDIA"]="$BACKUP_SOURCE_MEDIA"
BACKUP["$BACKUP_TARGET_DOCS"]="$BACKUP_SOURCE_DOCS"
BACKUP["$BACKUP_TARGET_CODE"]="$BACKUP_SOURCE_CODE"
readonly BACKUP

# Confirmation prompt before the dry run.
printf 'Will attempt to sync the following:\n'

for TARGET in "${!BACKUP[@]}"; do
    SOURCE="${BACKUP[$TARGET]}"
    printf '%30s <- %s\n' "$TARGET" "$SOURCE"
    [[ "$SOURCE" ==  */ ]] || error "Source directory '$SOURCE' should have trailing slash."
    [[ "$TARGET" == /*/ ]] || error "Target directory '$TARGET' should have trailing slash."
    [[ -d "$TARGET" && -w "$TARGET" ]] || error "Target directory '$TARGET' does not exist or not writable." 2
done

confirm 'Continue to dry run review?' || error 'Cancelled by user.' 3

# Perform the dry run of every sync and confirm all is well.
for TARGET in "${!BACKUP[@]}"; do
    SOURCE="${BACKUP[$TARGET]}"
    printf 'Sync: %30s <- %s (DRY_RUN)\n' "$TARGET" "$SOURCE"
    rsync --dry-run --stats -hvi -amHAX --delete --numeric-ids --chown=1000:1000 --chmod=D2755,F664 "$SOURCE" "$TARGET"
    confirm 'Accept changes?' 3
done

# Now that all measures have safely been confirmed by the user, any fault is on them. Sync it!
for TARGET in "${!BACKUP[@]}"; do
    SOURCE="${BACKUP[$TARGET]}"
    printf 'Sync: %30s <- %s\n' "$TARGET" "$SOURCE"
    rsync --info=progress2 -h -amHAX --delete --numeric-ids --chown=1000:1000 --chmod=D2755,F664 "$SOURCE" "$TARGET"
done

# Update on-backup metadata so we know what the name of the snapshot was and exit.
echo "$SNAPSHOT" > "$BACKUP_TARGET/.backup/snapshot.txt"
echo 'Backup complete!'
```

## Explaining Rsync Flags

If you are curious, here are the description of the `rsync` flags I used and why:

- `-amHAX`: Archive mode (preserve most things), prune empty directories, preserve hard links, ACLs, and extended attrs.
- `--delete`: Remove files from TARGET that no longer exist in SOURCE.
- `--numeric-ids --chown=1000:1000 --chmod=D2755,F664`: 
  In the TARGET copy, all files and folders should be owned by UID 1000, explicitly.
  I do this because files from containers will use their specific service users and whatnot.
  When reading from the backup, you mount it as root anyway, so you can copy them with other permissions then.

For the dry run:

- `--dry-run`: _(Duh?!)_
- `--stats`: Prints a nice summary at the end to check the number of modified files at a glance.
- `-hvi`:
  Human readable size numbers, verbose output, with itemized changes for each affected file, so you can see what is
  transferred, modified, etc.

For the actual run:

- `--info=progress2`: Show progress updates for transfer speeds and ETA.
- `-h`: Keep the human-friendly number formats, but don't print any info about the files, we already inspected them.

# Surprise!

The keen-eyed among you will have noticed that the source paths for `rsync` are not local paths, but use SSH, despite
my previous plan stating we would run this from the NAS console.
No, I did not hallucinate, the script works around an issue that took me by surprise.

Initially, when I brainstormed the plan, I saw the `cryptsetup` command was available under TrueNAS, and I just
_assumed_ it would work.
Wrote the script, and when I tested it, I got slapped with this error:

> Cannot initialize device-mapper. Is dm_mod kernel module loaded?

A quick search later, it turns out that since TrueNAS 24.10, the module is intentionally left out of the custom kernel
TrueNAS uses.
They argue that LUKS was never officially supported and people should only use ZFS via the TrueNAS UI or API, because
they do not want to support that use case [^3].
Which... I get it doesn't need to be officially supported, but why throw me a spanner in the works if I just want to
temporarily mount a separate drive to transfer some files?
It's a standard Linux kernel feature after all.
Oh, well...
Nothing we can do about it.

To work around this, we can use our main PC instead and copy the files via SSH.
I simply added my Yubikey's SSH public key to TrueNAS's `root` user in order to use `rsync` over the network instead.
If you don't use SSH for managing TrueNAS, you can manually enable the SSH service from the UI temporarily while
performing maintenance.

# Self-Critique and Improvements

My method does lose _some_ data, like taxonomy and metadata from some of our self-hosted services, we should
hopefully never be in the scenario where we need to restore from _this_ backup.

However, that's just a limitation of how I designed this script, and not of the methodology;
you could, of course, add some more automation to your services to export the database dump of your postgres containers
_(Immich is nice enough to do this for you![^2])_ and copy those over as well.
If you're less lazy than me and spend some time on `--cvs-exclude` or `--filter`[^1] rules, you can back up the entire
individual datasets of services, but ignoring caches, thumbnails, and other unessential data as to not waste space.

This will make the script a bit more complicated, but it's not too big a deal if you really care to make it a true
backup, instead of simply a disaster scenario one like me.

# Conclusion
 
We end up with a fast, semi-automated, zero-downtime, encrypted, and incremental backup of our most critical data, that
can be easily mounted on any Linux machine when in a pinch.

_Well worth it!_

[^1]: https://man7.org/linux/man-pages/man1/rsync.1.html
[^2]: https://docs.immich.app/administration/backup-and-restore/#automatic-database-backups
[^3]: https://forums.truenas.com/t/cryptsetup-and-dm-mod-kernel-module-load/33257
