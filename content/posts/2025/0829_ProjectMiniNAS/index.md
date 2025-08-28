---
title: "Project MiniNAS"
description: "A pragmatic guide for simplifying personal storage with TrueNAS and the Beelink ME Mini"
date: 2025-08-29
thumbnail: mininas0.webp
series: 'homelab'
category: 'technology'
tags: [ 'hardware', 'tutorial' ]
---

A pragmatic guide for simplifying personal storage with TrueNAS and the Beelink ME Mini.

<!--more-->

## Personal Motivation

You don't need to care, but I'll briefly explain what prompted my decision to upgrade my NAS.
My current system is a small form factor PC I built from scratch with my first internship salary way back in 2017.
It was my gateway project into homelab-ing, a time sink of research and online window shopping.
It's nothing fancy, but it's got a server grade motherboard, ECC RAM, and just enough space for two mirrored 10TB disks.

It has served me well over the years, however… it made me hate hard drives.
I've had one of them fail in warranty but only for the first 300GB-ish sectors;
I've had another show as degraded even though the short S.M.A.R.T. tests passed, but then the long one never completed;
they're big, bulky, spinney — I don't *want* them anymore!
I also don't like that I have to use a comically big PSU to power a PC that barely passes 55W.

So now that flash storage is much more affordable, and because of my recent
[infatuation with MiniPCs]({{< ref "posts/2025/0824_TheMiniPCRevolution" >}})
I figured it's a good time to jump ship and let go of the last hard drives I own _(except external backups*)_.

## Choosing The Hardware

This time around, the hardware chose me.
If you are part of the niche, unless you've been ignoring your subscriptions, you've probably seen just about
[every](https://youtu.be/35piaJgaeEA)
[tech](https://youtu.be/KPilnjN72Ls)
[youtuber](https://youtu.be/8VBnxEQKG3o?t=385)
[under](https://youtu.be/VZo-2Fq8v7M)
[the](https://youtu.be/0qGMonYrch4)
[sun](https://youtu.be/TkFfTekB3eM)
[and](https://youtu.be/xWdFk_rhIyA)
[their](https://youtu.be/UneuL4WZULw)
[dog](https://youtu.be/dQw4w9WgXcQ)
review this thing:

{{< figure
class="medium"
src="mininas0.webp"
alt="The Beelink ME Mini."
caption="The [Beelink ME Mini](https://www.bee-link.com/products/beelink-me-mini-n150) MiniPC" >}}

And what can I say — it looks pretty compelling.

### What I Really Like

**1. All Flash**

NVME drives are the best shit ever —
They don't have moving parts, they aren't sensitive to _(reasonable)_ accidental shock, they don't require any cables,
they are tiny and mount directly to the motherboard, they are fast as hell, they don't degrade simply being idle.
Sure they're much more expensive compared to hard drives at the moment, but for me, these advantages make it worth it.

**2. Power Efficiency**

The unit is very power efficient _(specifics later)_.
I like the idea of something so lightweight.
Personal cloud storage for the cost of a big LED lightbulb?
Yes please.
And if and when power goes out, this unit can run way longer on battery power
_(you should consider having a UPS for your homelab)_.

**3. Form Factor**

The case is a lovely cube shape about as tall as a coffee mug.
It has a clean, minimalist look and can blend in anywhere.
The power supply is built-in, so a power and network cable is all you need.
You could be a nomad and reasonably carry this around with you.

**4. Cheap**

I still cannot believe a NAS-capable, low power, compact, quad core, twelve gigs of DDR5 RAM, dual NIC, six freaking
NVME bays having-ass PC was 209$!
And sure, when you really think about it, the board itself is not that complicated, the components by themselves aren't
expensive either, but all of them put together like this deliver what feels like *WAY* more value than it asks of you.
Hell, the entire PC is cheaper than one 4TB NVME SSD, and you can shove six in here!

### What I Don't Like

**1. I'm Afraid Of eMMC**

The unit comes with a soldered-on 64GB eMMC flash storage, which on surface level sounds great.
You can install TrueNAS on it and have all six slots for pool use.
However, TrueNAS has the bad habit of logging to disk and there doesn't seem to be a way to stop it.
It's a small throughput, but even so, can accumulate to a few terra-bytes a year[^1].
I will come back to this later.

**2. PCI Lane Layout**

Probably because this is also marketed as a regular MiniPC — hell, it even ships with Windows preinstalled — Beelink
made the decision to have one slot _(the fourth for some reason)_ be a Gen 3x2 instead of a 3x1.
Guess that's cool for an OS drive, but here we don't need the speed, and the extra bandwidth goes nowhere when your
drive is in the ZFS pool being bound by the other stripes.
It would've been perfect if that one extra lane was put in place of the useless Wi-Fi card and hide an extra mini M.2
instead of having the on-board eMMC.

**3. No ECC**

Feels a bit weird to build a ZFS pool without RAM guarantees, but as many a forum post already debated, it's not the
end of the world.
ZFS is very resilient and has other error correcting methods and checksums in place.
There are many people who ran TrueNAS without ECC and without problems.
Surely it can't be so bad… *right*?

**4. No 10GbE**

Don't get me wrong, it's got dual 2.5GbE, and provided link aggregation works, should be plenty of bandwidth for the
kind of homelab use it's going to get.
I don't even have other 10GbE hardware at the moment, but would've been a nice-to-have just for future-proofness' sake.
I mean, come on! Just *one* of those NVME drives bottleneck-ed by the PCI-E Gen 3x1 lane is still able to push 8Gbps.

**5. But Hot Air Go Up?!**

This is mostly fluff and wouldn't consider mentioning it to normal people, but the top fan is an intake.
I would've expected to take advantage of the natural flow of hot air and instead be an exhaust.
I'm sure there's a deeper, engineering reason as to why it's like this, but it feels weird.

### And What About Drives?

For this I went with
[WD Red SN700 4TB](https://shop.sandisk.com/products/ssd/internal-ssd/wd-red-sn700-nvme-ssd?sku=WDS400T1R0C-68BDK0).
Not only were they locally available, but they are made for this kind of use-cases.
The speed is lower than high-end drives like Samsung, but still we don't care because network bottlenecks.

What we do care for is endurance. These drives are rated for **5100TBW**.
Your average consumer drives are anywhere from 300-1200TBW.
And mind you, this is just when writing, if you just read, it doesn't count!

To put this into perspective, the entirety of English Wikipedia is 46GB, 119GB with pictures[^2], let's round up to
120GB.
With 5100TBW you can back up a fresh copy of Wikipedia _42500 times_.
Or, looking at another angle, in the unrealistic scenario of writing back _2TB/day_ to your tiny homelab NAS, it would
take just shy of _7 years_.
It's much more likely some other electronic part will fail than the flash itself degrade.

There is also the power draw consideration.
Yes, really!
Checking out the specs[^3] we see a max power draw of 5.5W.
This is relevant because I found a thread [^4] of some ME Mini owners complaining about drive disconnects within
TrueNAS, which they concluded is because of SSDs with high max power draws.

Indeed, although not clearly listed in the specs, the internal power supply is labeled to output _12V @ 3.75A_, which
means **45W** total theoretical capacity.
The N150 CPU is rated at a max TDP of 6W.
With a full array of six such NVME drives, we get a napkin math of **39W** which leaves another 6W for the rest of the
components.

Granted, of course, you could get into a situation where you stress test it to the max, which is unlikely, but given
the aforementioned TrueNAS forum thread exists, not impossible!
There are some SSDs that consume up to 12W max, so if you get anything else, please do yourself a favor and make sure
they are low power as well and won't overwhelm the ME Mini's _(tiny)_ PSU.

## Planning The Pool Layout

After many considerations, this is the layout I plan to use.
I find this maximises flexibility and expandability in future.

```text
                  ╔═══════════════╗
           ┌─ S1 ─╢               ╟─ S6 ─┐
           │      ║    Project    ║      ├─ Pool 4TB
 8TB Tank ─┼─ S2 ─╢    ┅┅┅┅┅┅┅    ╟─ S5 ─┘  (Mirror)
 (RaidZ1)  │      ║    MiniNAS    ║
           └─ S3 ─╢               ╟─ S4 ─── TrueNAS Boot
                  ╚═══════════════╝
```

I did not want to get all five drives at once _(mixing batches is a good idea)_, so this way allows me to start small,
with the 4TB that will be a dedicated mirror pool conveniently filling the right bank.
Mirrors are much easier to use when in a disaster scenario and usually recommended for the most sensitive of data.
This is where I'll put critical data and things I never want to lose.

Later on, I will get three more drives to fill the left bank.
Here a RaidZ1 gives us 8TB of capacity with one drive of redundancy.
This will host the things I don't want to lose, but wouldn't be the end of the world if I did.

The 4TB and 8TB effective size of our ZFS pools conveniently match typical sizes of external hard drives.
This will make it easy to replicate and restore our datasets.
There's a dedicated section about backups later in the article.

If you want to consider some other alternatives, you could:

- Have a 5-drive RaidZ1, have a single drive of failover because you feel confident in your SSDs and external backups.
  This will net you a nice, round 16TB of usable storage, but will make it ever-so-slightly harder to back up.
- Do a 5-drive RaidZ2 and effectively have the left side be 12TB of storage and the right side be one OS and two parity.
  For the most paranoid out there. Still two drives of spare, but now it's *any* two drives.
  Some would tell you to prefer having 6 drives for Z2, so the striping is more even but remember that ZFS has
  compression and is not traditional RAID, and any would-be performance penalties are again irrelevant as we are
  bottleneck-ed by the NIC anyway — tl;dr don't worry about pool width [^5].

If you don't use slot 4 for TrueNAS, but rather the eMMC, then you could:

- Do a 6-drive RaidZ2 and have 16TB with two drive failover — the dream.
- Put a single-drive pool on it and use it for fungible data _(that doesn't need backing up)_, like hosting a shared
  Steam library, or holding your downloaded "Linux ISOs".

Do whatever works best for you.

## Installation

{{< figure src="mininas1.webp" alt="Components of the build." caption="The gang is all here! Mug for scale." >}}

To open it up, turn the unit upside down.
With a sharp and delicate instrument, remove the rubber feet, which hide four standard cross screws.
Once those are removed, carefully flip it back over and the case should slide off effortlessly.
Wow, it's beautiful!

{{< figure src="mininas2.webp" alt="View of MiniPC internals." >}}

We can *very carefully* disconnect the Wi-Fi card, which I already disabled in BIOS — maybe it will save an extra watt.
A bit of electrical tape on the antenna wires for good measure.

Next, identify the slots you want to use, peel off the protective cover and add the drives.
Note the slots are _reversed_, so the top of the NVME should touch the heat sink.
And, pro-tip, make a note of their serial number _(labeled: `S\N`)_ to slot mapping, so you know which drive to pull out
in case you need to do a hardware change later.

{{< figure src="mininas3.webp" alt="View of MiniPC internals with components mounted." >}}

So nice!

### Checking Out That eMMC

I booted the NixOS live ISO to check on the eMMC really quick before disabling it and give you more context as promised.
Lucky for us, eMMC health reporting is now part of the standard and available in Linux 4.0 onwards.

Here are some useful commands[^6].
The last two are the relevant ones, showing the reported lifetime and EOL status, a.k.a. how degraded the chip is.
Monitor these closely if you plan on using the eMMC for TrueNAS.

```shell 
$ cd /sys/class/mmc_host/mmc0/mmc0\:0001
$ cat name type oemid manfid rev life_time pre_eol_info
DV4064
MMC
0x0100
0x000045
0x8
0x01 0x01
0x01
```

Why am I paranoid again?
Well, as mentioned before, TrueNAS likes passively writing logs to disk.
In my current NAS, over the last few months I had this report for my boot SSD:

{{< figure src="truenas0.webp" alt="Boot disk I/O reports of old NAS." caption="Boot disk I/O reports of old NAS." >}}

A mean transfer of 370KiB/s.
That's peanuts, but let's extrapolate:

_370KiB/s × 60 × 60 × 24 × 365 ≃ **12TiB/yr!**_

That is an enormous amount of spam for such a tiny chip in my mind.
Over five years, which is the minimum amount of time I expect this to last without maintenance, that would be 60TB of
write on a 64GB drive, or about 1000 cycles.
Modern eMMC should last up to 3000 cycles, which is the good news relief for people who do want the eMMC.
As long as you monitor the degradation every few months, you should be good to go.

That being said, I am paranoid, and don't really need more than 5 slots for what I plan to do, so I will disable it.
In the future, I might reconsider, but for now I prefer peace of mind.

### BIOS Tweaks

I did the following changes to the BIOS, just in case you want to follow along _exactly_.
You don't need to do all these settings, but my philosophy is simple: _Disable all unused features!_

- **Main**
    - **Adjust System Time** because why not? I usually follow [time.is](https://time.is).

- **Advanced**
    - **Connectivity Configuration**
        - **Wi-Fi Core** → `[Disabled]` We will not be needing it.
        - **BT Core** → `[Disabled]` Ditto.
        - **Discrete Bluetooth Interface** → `[Disabled]` I said no bluetooth!
    - **Power & Performance**
        - **GT - Power Management Control**
            - **Disable Turbo GT frequency** → `[Enabled]` We won't be using the integrated GPU for anything.
    - **ACPI Settings**
        - **Enable Hibernation** → `[Disabled]` This will run 24/7.
        - **ACPI Sleep State** → `[Suspend Disabled]` Same reasoning, get rid of features you don't need.
    - **PCI Subsystem Settings**
        - **Re-Size BAR Support** → `[Disabled]` Again, we will not be needing GPU stuff.
    - **USB Configuration**
        - **Legacy USB Support** → `[Disabled]` Our installation drive is EFI capable anyway.
    - **CSM Configuration**
        - **CSM Support** → `[Disabled]` Not needed.

- **Chipset**
    - **PCH-IO Configuration**
        - **SATA Configuration**
            - **Sata Controller(s)** → `[Disabled]` We don't have any SATA drives.
        - **HD Audio Configuration**
            - **HD Audio** → `[Disabled]` Won't be listening to the NAS anytime soon.
        - **SCS Configuration**
            - **eMMC 5.1 Controller** → `[Disabled]` Only set this if like me, you don't want to use the eMMC for now.
            - **eMMC 5.1 HS400 Mode** → `[Disabled]` Otherwise, turn off this speed optimisation, might lead to better
              longevity.
        - **State After G3** → `[S0 State]` Rather cryptic, this will power on the device automatically after a power
          loss.

- **Boot**
    - **Setup Prompt Timeout** → `3` Give ourselves a bit more reaction time.
    - **Boot Option** → `[NVME #1]`, `[USB Device #2]`, `[Disabled #3+]` Get rid of extraneous boot options.

### TrueNAS Installation

The installation for TrueNAS went swimmingly simply following the TUI prompts.
After it was done and a reboot, waited for initial setup, which took a little,
I made a note of the MAC address to give it a static DHCP lease on my router.

You can get it by entering the Linux Shell from the menu, then running `ifconfig -a`, which should show the interfaces
`enp1s0` and `enp2s0` for the left and right ports respectively. Or, you could `cat /sys/class/net/enp1s0/address` for
a cleaner output.

After setting the IP, reboot so the box obtains it.
The rest of the setup can be done via the WebUI.

## Configuration Advice

Here is a checklist of things to do after you install TrueNAS.
This is just an overview, for the best results make sure you [RTFM](https://www.truenas.com/docs/).

### Pools

**Creating a ZFS Pool**

We need a place to store our data.
Go to _Storage_ → _Create Pool_.
Give it a name (`pool` and `tank` are popular choices), of course enable encryption
_(the default AES-256-GCM is best choice here)_, download and backup the key for it.

Next in the data, choose a layout and the disks to allocate to it.
I only have two drives at the moment and as described in the plan, this will be a mirror.

Leave all the other VDEVs _(Metadata, Log, Cache, Spare, and Dedup)_ alone, even if you had the extra drives to spare.
They are indeed cool, but only make sense in an enterprise or mixed HDD-SSD scenario.

**Enable TRIM.**

By default, TrueNAS does not enable TRIM on pools.
But we have SSDs, so let's go do that.
First, check that your SSDs indeed support TRIM.
In the shell, run `lsblk --discard`.
The drives support TRIM if the columns `DISC-GRAN` and `DISC-MAX` are non-zero values.
If yes, turn it on for your pool in:

_Storage_ → _ZFS Health_ → _Edit Auto TRIM_.

**Moving the System Dataset**

It is by default created on the first non-boot pool you do, which we just covered.
This is where some configurations are stored as well as metrics are collected.
It's here so the boot pool doesn't get spammed by _(even more)_ constant writes…

Well, since TrueNAS runs on a proper NVME, we don't need to worry about the TBW of that, and you can safely move it
back.
Obviously, _do not_ do this if you installed on eMMC!

Word of warning though, if you lose the boot drive, you lose the dataset, so be wary.
Be that as it may, you can also manually create backup files and download them from the GUI.
More on backups later, but if you wish to change it:

_System_ → _Advanced Settings_ → _Storage_ → _Configure_

### Data Protection

Next we'll configure some automated tasks to help protect our data further.

**Scrub Tasks**

A scrub is a read-only pass through the data to verify it against checksums.
It is recommended you do so periodically.
TrueNAS comes by default with one every month, but usual consensus I've seen online is once a week to be good practice.
You can scrub however often you want, SSDs only degrade when writing.
It's nonetheless still a good idea to keep it out of active hours.

Go to _Data Protection_ → _Scrub Tasks_ and edit the existing one or create another.
I like to have it done late Sunday nights _(technically Monday mornings)_, so it would be a threshold of 6 days, and a
custom schedule cron of `(0 4 * * mon)`.

[_Scrub, scrub, scrub, my boy!_](https://youtu.be/ofbhkbk42Jc?t=63)

**Not so S.M.A.R.T.**

We would also usually enable automatic S.M.A.R.T tests, but it seems like currently TrueNAS does not support S.M.A.R.T.
tests for NVME drives[^7].
The UI lets you, but apparently the tests aren't really running?
You can still run the tests yourself in the console by running:

```shell
$ nvme device-self-test /dev/nvme0 -s 1 # 1 for Short, 2 for Long
```

Of course, this can be automated as a cronjob.
Hopefully this gets fixed in later updates.
You could set the GUI task and hope it fixes itself later as well.
Anyway, I'd say one short test a week and one long test a month is enough.

**Periodic Snapshots**

One of the killer features of ZFS, snapshots give you rollback superpowers.
Since ZFS is a CoW _(copy on write)_ filesystem, you can keep references to files in points in time, allowing you to
rollback anything, even deleted files.

Snapshots don't make copy of the data, only take note of their index, so you can pretty much abuse them as much as you'd
like.
Snapshots also play an important role in that backup section I keep deferring.
For starters, let's create the sane safety net:

_Data Protection_ → _Periodic Snapshot Tasks_ → _Create_

Select your pool, and choose how often and how long to retain them.
The amount of snapshots doesn't matter if data doesn't change much.
It only gets expensive if you store ancient copies of often changed files.
For general use, I recommend a recursive nightly snapshot with a lifetime of one month.
Set the naming schema to something like `nightly-%Y%m%d-%H%M`, run daily at midnight.
Do allow empty snapshots, they cost nothing but keep the snapshot list consistent and helpful to humans.

Manual snapshots are a great way to grant you a safety net before doing something risky.
They can be done on a per-dataset level, recursive or otherwise, from:

_Datasets_ → _\<Some Dataset\>_ → _Data Protection_ → _Create Snapshot_

Just make sure not to forget to delete them when they're not needed anymore.

### Users, Datasets, & Shares

Next we need to define some users, so that we can access this data remotely.

_Credentials_ → _Users_ → _Add_

Fill in the form.
Try matching the UID with the ones you have on other Linux computers.
For example, I keep `UID=1000` for my main personal user.
Typically, I have `1xxx` for humans and `2xxx` for homelab / service users.
If you do custom numbers like this, do not create a primary group automatically, since it will not use the same ID.
Create it manually afterwards.
You don't need a home directory, and it's off by default.
You can add any SSH keys and stuff later.

Let's also create some datasets:

_Datasets_ → _\<Your Pool\>_ → _Add Dataset_

For the preset, leave as _Generic_ if using any one share type, or _Multiprotocol_ if you need both NFS and SMB.
I like things simple, so I go for the default _POSIX_ unless otherwise required.

Also take a look at the advanced options, some interesting ones are:

- **Quotas** can be used to limit the size of these datasets; it's useful when you want to say, give each person in your
  household 1TB of storage, and it will show up in the reported max size of the shares.
  You can also reserve space ahead of time, to make sure growing datasets don't restrict each other.

- **Compression** is on by default and LZ4 is a good balance between space-saving and efficiency.
  I will say that it's sometimes useful to turn this off, for example on a dataset with a quota that is supposed to also
  be backed up as regular file copy _(an `rsync` on some `ext4` external drive, not via ZFS)_, to ensure the data will
  actually fit, and not just appear to because it's compressed on your NAS.

- **Atime** is off by default, leave it at that.
  It's good to have in scenarios where you need more auditing metadata, but for often-read files it will cause useless
  writes to update the file nodes.

- **Snapshot Directory** if set to visible, a `.zfs` subdirectory will appear in the dataset, letting you browse through
  your snapshots as regular files; you can turn this on or off at any time.
  If you are in the TrueNAS shell, you can enter it without being enabled, too!

- **Record Size** defaults to 128K, it's basically how big file chunks are and the breadth of write operations.
  Since we are on SSDs, we can lower this to 16-32k since seek times are negligible unlike HDDs, and might even decrease
  amount of write for small files.
  Alternatively increase it for datasets which will only store big files (images, videos).
  The default is good enough for most, I did not research this a lot, but it's cool to know it exists.

After it was created, we can select it again and edit the ACLs.
For my example, I made a dataset that will be my personal storage, so the user and group are set to my user, with an
access mode of `750` _(user can do anything, group can read and execute, others can't do anything)_.
Make sure to apply the user and group, since by default they will inherit the `root` user from the pool.

I will only briefly touch on setting up network shares.
Just above the permissions group / tab / thing there's a _Roles_ section which allows creating an NFS share.
You can also do SMB if that's your thing, but I only will use this one from my main Linux workstation.
Since I only want one client for this share _(me)_, in the advanced options I'll put my user in the _Mapall User_ and
_Mapall Group_ dropdowns, as well as add the IP of my PC _(which also has a static DHCP lease)_ to the _Hosts_ list.

Then, from my PC, I can mount it like this:

```shell
$ sudo mount -t nfs4 nas:/mnt/pool/vault /mnt/vault -o defaults,tcp,rw,noatime,noauto
```

### Other Tweaks

**Tweak the Dashboard**

Just for fun, go to _Dashboard_ → _Edit_ and see how you can customise and arrange the widgets to suit your style.

**Set your Timezone**

I didn't remember being asked during install.
It will be confusing to see reports in the wrong timezone.

_System_ → _General Settings_ → _Localization_

**Lock Down The Console**

This will make it so TrueNAS requires the admin password before granting shell access on the MiniPC TTY itself.

This is just good practice, and we won't be interacting with the MiniPC directly, so it's not going to be an
inconvenience either.
I do concede that if you have bad actors plugging keyboards into your home NAS you have bigger problems…

_System_ → _Advanced Settings_ → _Console_ → Uncheck _Show Text Console Without Password Prompt_

**Disable Telemetry**

The anonymous statistics usage collection is opt-out.
And rather well hidden too:

_System_ → _Settings_ → _GUI - Settings_ → _Other Options_ → _Usage collection_

## Backups

It is finally time to talk backups, because of course, repeat after me: _"Raid is NOT a backup!"_[^8]

Before moving any actual data to your NAS, create a small set of sample volumes and some data
to make sure your backup flow works, and you are preserving the right snapshots and such.

Back in the layout planning section I said that separate 4TB and 8TB pools are easier to back up because we'll be using
off-the shelf external hard drives.
This approach will still work if you have a single large pool and enough external drives to cover the effective size,
as long as you divide your dataset quotas such that you can fit them nicely into the different disks.

Either way, the backup drives should be kept offline, and ideally offsite.
Stash them at your parents' or friends' place, or in your work locker or something.

### The 3-2-1 Strategy

The golden rule is you should have three copies of your data, on two different mediums, and one kept offsite.
I will bend the rules, and instead of different mediums, I'll say different filesystems.

You should have an answer to every failure:

- **One drive dies**: You have redundancy. Don't panic — buy another drive and resilver your pool.
- **All parity drives die**: Unlucky. Replace them, recreate a pool, restore from offline external ZFS backup.
- **My offline backup drive dies**: You still have redundant storage, get a new backup drive
  _(if you don't already use multiple on rotation)_ and replicate the pool.
- **Entire NAS dies in a housefire**: Use the offsite backups: the `ext4` backup for immediate consumption, hold onto
  the ZFS backup until you can get a new NAS.
- **You die**: You don't need the data anymore — all good!

### Configuration Backup

The TrueNAS boot pool is running on a single drive without redundancy.
If it fails, and we reinstall TrueNAS, it will be a pain to have to create the same settings again.
Luckily, we can export them to have for later.
Do a backup every time you change settings, or before you update TrueNAS:

_System_ → _General Settings_ → _Manage Configurations_ → _Download File_

### ZFS Backups

> ***⚠️ Disclaimer:***\
> *I will tell you what I ended up doing, but I'm not an advanced ZFS user and I could be wrong or skipping details,
> since I'm still learning this replication thing myself, and I weirdly found the CLI to be easier than TrueNAS UI.
> The following is not professional advice, and I am not responsible for any would-be data loss.
> Feel free to [skip to the next section](#stats-and-benchmarks) if you want to do it your own way.*

Backing up with ZFS can be more feature rich, since you can preserve dataset properties, hold multiple snapshots,
benefit from compression, etc.

TrueNAS's replication tasks UI seems more geared towards always online pools and remote systems rather than local
external drives, so I instead opted for a much more low-level and involved, but sane and observable set of commands,
using `zfs` directly from TrueNAS's shell.

_(All the commands should be run on the TrueNAS host as root; if you're logged as the admin user, use `sudo -i`.)_

**Creating a Backup Pool**

Plug your external drive into the NAS and follow the same steps to create a pool, this time however, using a single
disk stripe and ignoring TrueNAS's pleas against the bad practice.
Don't enable encryption on this one, you'll see why in a sec.
This is just so we have fewer things to worry about.

**Bootstrapping the Backup**

Create a base snapshot of your source pool, ideally before you write any data on it.
Choose a useful naming scheme, I like `backup-%Y%m%d`.
These snapshots are managed by us manually, so we need to know what's what.
For simplicity of reading these, I will use auto-incrementing integers here instead.

```shell 
$ zfs snapshot -r pool@backup-0
```

We can now replicate it to the backup.
The first hurdle is we cannot replace another pool's root dataset.
Instead, we will replicate the source root dataset as a child dataset of the backup.

```shell
$ zfs send -Rwv pool@backup-0 \
  | zfs recv -F -o atime=off -o readonly=on backup/pool
```

If you navigate in the UI to the _Datasets_, you should see a locked dataset named `pool` under the backup pool.
Click _Unlock_, provide the key manually, then paste in the encryption key of the source pool.
After unlocking, you will notice it is marked as its own encryption root, because we transferred it with the `-w` or
`--raw` option.
This is why we did not encrypt the backup drive itself, any replications would be encrypted anyway.

**Making Incremental Backups**

Currently, I only plan to keep one snapshot as an offline backup, which I will update once a month.
Let's add some data to the pool _(here, `nested` is a dataset under our source pool)_:

```shell
$ echo 'world' > /mnt/pool/nested/hello
```

Now let's create a new snapshot to preserve it.
The `-r` flag is crucial, we want recursive snapshots:

```shell
$ zfs snapshot -r pool@backup-1
```

We can send it over as an incremental.
Pass the `-i` option with the current snapshot that is backed up (`backup-0`), and change the positional argument to
the new snapshot (`backup-1`):

```shell
$ zfs send -Rwv -i pool@backup-0 pool@backup-1 \
  | zfs recv -F -o atime=off -o readonly=on backup/pool
```

**Sanity Checks**

We can verify the snapshots are there:

```shell
$ zfs list -t snapshot -o name | grep -E '(^|backup/)pool'
backup/pool@backup-0
backup/pool@backup-1
backup/pool/nested@backup-0
backup/pool/nested@backup-1
pool@backup-0
pool@backup-1
pool/nested@backup-0
pool/nested@backup-1
```

And we can verify the data is there, both these commands should output `world`:

```shell
$ cat /mnt/backup/pool/nested/hello
world
$ cat /mnt/backup/pool/nested/.zfs/snapshots/backup-1/hello
world
```

**Cleaning Up Snapshots**

Now that our snapshot is replicated, we can delete the previous ones.
Before running these for real, pass the `-n` argument to do a dry run.

```shell
$ zfs destroy -v -r backup/pool@backup-0
$ zfs destroy -v -r pool@backup-0
```

**Scrub and Dismount**

It's good practice to perform a scrub of the data on the backup drive to ensure everything is in order.
You can do this via the TrueNAS UI, or with `zpool scrub backup` / `zpool status -v backup`.

To dismount, you can do it from the UI, make sure not to enable destroy data _(duh)_ and don't delete saved
configurations, so TrueNAS does not forget other tasks related to it, you might have added:

_Storage_ → _\<Backup Pool\>_ → _Export/Disconnect_

Next time, import it with the _Import Pool_, you should see it in a drop-down.

**Restore Backup**

I'd advise against restoring from backups on non-pristine pools.
But here's how to perform a restore if you ever wipe your datasets because of a catastrophic hardware failure.
Here there's a little caveat, since we cannot replace the pool root dataset, we will need to do it for each top-level
dataset:

```shell
$ zfs send -Rwv -i backup/pool/nested@backup-1 | zfs recv -F pool/nested
```

Similarly, repeat for each `nested` dataset.
When you go back in the UI, you should see that every dataset is locked, use the same technique of unlocking it with
the manual key.
But now we can do an extra trick: reparent it.
With the unlocked dataset, edit the ZFS encryption tab again, and tick the box to inherit encryption settings from
parent.
This will defer encryption to the root dataset once again.

You are now restored!

### R-Sync Backups

I also recommend you keep your _very very very important_ data onto a
LUKS-encrypted plain `ext4` formatted external drive, "just in case" of the unlikely event your will royally screw up
your ZFS restorations;
you can use `rsync` for this, it's simple and works really well.

For the sake of brevity, I will skip the details for this, but [here](https://superuser.com/a/1288301) is a good
starting point to see how you can devise a script to do this.

## Stats and Benchmarks

Here are a few tests and measurements I've done.
Disclaimer: at the time of writing I only had it for about 5 days, and I only set out to _observe_ how it behaved
rather than try to tweak and push its limits.
These are not as scientific and comprehensive as what you'd get in a proper tech review, just my observations as a
casual user.

### Thermals

I did not tweak any fan curves, CPU voltages, or thermal throttle thresholds in the BIOS.
The unit can sometimes get warm to the touch, but never hot.
The fan is spinning, but you won't hear it unless you put your ear very close.

From TrueNAS reports over the last few days, the CPU was idling at a pretty constant **38°C**, with the maximum value
of 51°C in small, short peaks.
The SSDs were all consistent too, basically always at **46.5°C**.

These are not mind-blowing numbers, but for the very low fan RPM and noise levels the unit delivers, they are
acceptable numbers.

### Transfer Speeds

Nothing spectacular to report here, as expected, it uses all the available bandwidth.
On a 1GbE, you will get up to ≈100-120MB/s; on 2.5GbE you will get ≈250-300MB/s.
Of course, there will be losses depending on other involved hardware, cables, etc.

I have _(still!)_ not gotten a 2.5GbE network switch, so at the moment I am capped to 1Gbps.
I am really sorry that I can't give you proper benchmarks, but here are my results:
On an NFS share mounted from my NixOS PC, I get about _96MB/s write_ and _118MB/s reads_, about what you'd expect.

If you want to benchmark it yourself, try these commands:

```shell
# Test write speeds by chucking random data.
$ dd if=/dev/urandom of=/mnt/share/datadump bs=8M count=1024 oflag=direct status=progress

# Reset the caches, or we will get BS speeds.
$ sync
$ sudo bash -c 'echo 3 > /proc/sys/vm/drop_caches'

# Test read speeds by reading that junk back.
$ dd if=/mnt/share/datadump of=/dev/null bs=8M count=1024 oflag=direct status=progress
```

The `bs` parameter determines the block size to chunk with and `count` just says how many chunks to process.
You can play around with these but _please be careful_, it's nicknamed **disk destroyer** for a reason!

### Power Consumption

With my unit and configuration settings
_(remember that I removed the wireless module, and disabled the eMMC and SATA controllers in the BIOS)_,
running TrueNAS without any drives results in an idle draw of just 6.5W.
After adding in the other drives, it idles at 9.6W, which is consistent with the WD specs of 1W in idle.
We can extrapolate a _12-13W_ idle with a full array of drives.

With my three populated slots, I got a peak draw of _14W_ while saturating the network share, because I use this purely
as a NAS without running any services _(and this is the only way I'd use such a device)_.
If you were to benchmark it "from within" and actually run synthetic benchmarks on the CPU and drives, you can expect
to get to the _30-ishW_ mark[^9].

However, let's get back to our use case, which is NAS _only_.
Averaging a few peaks of use with mostly idling in a personal storage homelab scenario, let's generously say _15W_,
that comes up to about **11kWh/mo**.

From previous testing, my old NAS made of individually purchased parts averages at _55W_, or 40kWh/mo.
For my personal case, that's _4x_ increase in energy efficiency, love to see it!

For a bit more perspective, the average power consumption per capita in the EU is about 490kWh/mo[^10], just about my
situation as well _(yay for electrical heating)_.
I should expect this NAS to be **only ≈2%** of my electrical bill, that is impressive!

## Conclusion

The total cost of the unit, the three drives, and the external backup came up to _4122 RON_ ≃ _813 EUR_ in my case.
The 4TB of _(current)_ capacity it gives is nothing to write home about, and while the energy savings are definitely
there, it's way too expensive to even consider it paying for itself over time from that.
Even so, I do not regret the purchase — that price is comparable to what I paid for my old custom NAS.

If you really want ECC RAM and 10GbE, there are two other models I've looked at, but their barebone model costs as much
as my final 4TB mirror, they aren't as power efficient, and they *support* ECC, but don't *ship* with it, so that's
even more upfront cost:
The [NASync SXP480T Plus](https://nas.ugreen.com/products/ugreen-nasync-dxp480t-plus-nas-storage?from=nas-nasync-series)
is nice but only has 4 drive bays _(not including OS one)_, and the
[FLASHSTOR 6 Gen2](https://www.asustor.com/product/spec?p_id=90) which I immediately dismissed because I vowed
[never to buy ASUS again]({{< ref "posts/2025/0508_HowILostTheSiliconLottery" >}}).

Time will tell if I made the right choice!

[^1]: https://forums.truenas.com/t/continuous-writing-activity-on-the-boot-disk-every-second/5773/8

[^2]: https://library.kiwix.org/#lang=eng&q=&category=wikipedia

[^3]: https://www.techpowerup.com/ssd-specs/western-digital-red-sn700-4-tb.d1621

[^4]: https://forums.truenas.com/t/using-beelink-me-mini-with-6-nvme-drives-only-4-are-useable-in-truenas-scale/47306

[^5]: https://www.perforce.com/blog/pdx/zfs-raidz

[^6]: https://wiki.friendlyelec.com/wiki/index.php/EMMC

[^7]: https://forums.truenas.com/t/problems-with-the-new-nvme-s-m-a-r-t-test/24337/2

[^8]: https://www.raidisnotabackup.com/

[^9]: https://nascompares.com/review/beelink-me-mini-nas-review/#Beelink_ME_Mini_NAS_-_Performance_and_PowerHeatNoise_Testing

[^10]: https://data.worldbank.org/indicator/EG.USE.ELEC.KH.PC?locations=EU&start=1996&view=chart
