---
title: "How I Lost The Silicon Lottery"
description: "A tragicomedy about being an early adopter in the tech ecosystem. (Specifically: AMD 7950X + 7900XTX, ASUS X670E-HERO)"
date: 2025-05-08
thumbnail: pc0.webp
category: 'technology'
tags: [ 'rant' ]
---

A tragicomedy about being an early adopter in the current tech ecosystem.
<!--more-->

---

## Humble Beginnings

I turned 18 years old in 2014, and I prepared to celebrate such an event by saving up on my allowance and the pay from
my summer _"internship"_ with the purpose of splurging out on a custom gaming PC, fully built by me, for the first time
in my life.
I don't remember exactly how much it cost, but budgeting it was not my main concern.
Rather, I wanted something sturdy, reliable, that I could use and abuse for many years.
In tech, future-proofing is definitely not a thing, but delaying the upgrade purchase means there's more time to save up
for it.

It was an AIO water cooled I7-5820K with 32GB of RAM on an AsRock Fatal1ty X99X Killer, with a GTX 780Ti graphics card 
(later upgraded to 1080Ti), sleeved PSU extension cables, in the iconic NZXT H440 case.
My pride and joy, a reliable PC that still works to this day, and is waiting patiently on my spare desk to be turned on
again.

## Desire To Upgrade

The year is now 2022, almost 8 years later.
AMD shows off their impressive AM5 lineup.
DDR5 memory with blazing speeds?
A socket change, ton of cores, finally moving pins away from the CPU and onto the motherboard, which always irked me.
And their new RDNA3 flagship GPUs with impressive price to performance comparison to nVidia, while also having great
Linux support _(foreshadowing)_?!

Who wouldn't be _at least tempted_ to upgrade?
And for me, it was also a great opportunity to try and jump ship from Intel and nVidia, for several reasons:

- Intel was lagging behind in lithography;
- As a homelab enthusiast, I didn't like Intel as a company not enabling ECC memory support on non-enterprise models;
- nVidia was suffering from exorbitant prices in my area because of the crypto-bro craze;
- nVidia worried me with the new fire hazard power connector;
- nVidia _still_ did not properly support Linux.

My rationale was, since it was a platform, socket, and RAM revision upgrade, with hardware powerful enough to suit my
needs _(since I was still enjoying my time on 8-year-old hardware)_, a good enough point to upgrade, and I could sail
the sea for 8 more years, possibly upgrading when a new socket or DDR6 came to be.
All my friends with AM4-based PCs were having a wonderful time, and I felt I could vote with my wallet against companies
I no longer resonated with.
Little did I know I was sailing straight into the eye of the storm.

## The Build

Armed with more disposable income than sense, as a delayed birthday combined with a Christmas present to myself, I built
my current PC:

{{< figure src="pc0.webp" alt="Black and white PC in a dark environment.">}}

The desk is on the other side of the wall behind it, and cables are passed through it, so I never have to deal with the
sound and heat near me — it instead acts as the space heater in my hallway.

The specs:

- **CPU:** AMD 7950X _(+ NZXT Kraken X73 cooler)_
- **RAM:** Kingston Fury 64GB DDR5 _(*)_
- **GPU:** AMD 7900XTX
- **MBD:** ASUS X670E-HERO
- **SSD:** Samsung Evo Pro 990 1TB _(x2)_
- **PSU:** beQuiet! Dark Power 12 1000W
- **CAS:** NZXT H7 Elite

_(*) - Not the original RAMs, more on this later._

{{< figure src="pc1.webp" alt="Closeup of the internals.">}}

Just because it is out of sight does not mean it shouldn't look dope!
I went for all-black components, white-only lighting theme, and I think it worked out great.
I am very satisfied with the looks of the end product!

## The Beginning of the ASUS Curse

At the time I was doing my build this was the only available board for purchase _(for me at least)_ that had three
display outputs on the rear IO: two USB-C display ports and one HDMI.
This was crucial as I planned to have a Linux host running on the integrated GPU and pass the dedicated one with VFIO
for a gaming VM.
It also had a ton on USB ports, it looks great and matches the theme.
A bit expensive, but I was already splurging, so might as well.

This was the first and definitely the ***LAST*** ASUS motherboard _(or product)_ I purchase(d), for reasons that will
soon become apparent.

Right out the gate, I was hit with the first hurdle: DDR5 memory training[^1].
Because DDR5 is much denser and operates at a higher clock than DDR4, it requires some special calibration before the
system can use it.
Basically, it adjusts its voltages, frequencies, and such-and-such, so the first boot of a PC is expected to be a few
minutes long, depending on the capacity.

However, said calibration can be reused via a mechanism called _"Memory Context Restore (MCR)"_ on AM5.
If you look it up, you will either find people swearing turning it on fixed their boot times, or others complaining it
causes some other issues with unrelated hardware, mainly involving power cycling, and sleep states.

On my ASUS motherboard however, enabling it ***removed my ability to POST***, getting stuck on memory training codes
_(usually 15)_.
I couldn't even get back to the BIOS to remove it, so the solution was either clearing my CMOS and starting over, or
removing one of the RAM sticks.
Great.

But it wasn't just MCR, it was RAM speeds as well.
See, DDR5 lies a bit, the speed you see on the specs and packaging is *not* the base speed, it is the speed using EXPO
mode, AMD's alternative to Intel XMP, basically pre-configured overclocking settings.

Turning EXPO mode on made me unable to POST again, regardless of MCR usage. *Sigh…*

In the end, I found a configuration that was stable, but just imagine the horror of having to try one stick, two sticks,
this EXPO, that EXPO, manual timings, and every time you want to do a change you have to wait two minutes for the
memory to train.

So, exhausted, I compromised on the two-minute boot sequence for the time being, because I tend to never fully power
down my PC, just suspend it to RAM.
This gave me the time to notice the other issue.

## AMD's Quality Control

Many users noted that their GPU hotspot reached temps of 110C and throttle in normal use.
AMD made an official statement[^2], and even offered to remedy the issue, which turned out to be a faulty production
batch with not enough coolant in the heat pipe.

Problem was, I'm not a direct customer of AMD.
I got my card from a reseller of a reseller, and the official diagnosis of this came well over the 30-day return policy.
My only option was to attempt to claim warranty, but that takes time, and I was sure that I'll get the canned
_"yeah bro works fine, AMD cards just run hot mate"_ response.

Fortunately, the problem was mostly mitigated with two fixes: a _-10%_ power limit in the driver, and using the GPU
support bracket to make sure the backplate was straight with no sag.
This seemed to improve cooling by a few degrees, for me at least, and my hotspot stayed under 90C, unless I'm playing
something really badly implemented.
Good games, like KCD2, run perfectly well with a hotspot of even 75-80, so your mileage may greatly vary.

If only this was the only quirk!
I also discovered that idle power draw greatly increased if I had multiple monitors connected to it, as reported by many
others[^3].
This seems like a driver issue, but fortunately since this GPU was mostly used on a VM, I was fine using just the one
monitor, and the other two ran on the host.
I have no idea if this is still a thing, I stopped caring long ago.

## The AMDGPU Reset Bug

Speaking of virtual machines, I was forced to put my PC to sleep and wake it up again every time I wanted to boot my VM.
That also includes every time I close down the VM to reboot it.
Otherwise, if I boot the VM, it just hangs in a black screen.
Why?

AMD has had this issue on many GPUs for years now, and from what I can tell, nobody at AMD knows why it happens, because
it is still an issue, but not on all GPU models?
I don't know enough about this to comment on, but there is a kernel module workaround[^10], but which I haven't used
since sadly it doesn't seem to support the 7000 series _(yet?)_.

Now imagine my pleasure when I had to install windows on the gaming VM, and carefully time killing off the VM right
after the power-off, and do a suspend / wake cycle before starting it again because Windows Update needs like two to
three reboots even though you told it to _Update and Shut Down_, and then doing it again because it decided to replace
the AMDGPU drivers you installed yourself — God dammit Micro$oft!

## The UEFI Roulette

Having reached a not ideal, but stable and usable configuration, I proceeded to enjoy my time using the PC, and wrote
off the shortcomings as expected kinks that will surely be ironed out with BIOS updates… right?!

I checked a couple of months later, and updated the UEFI with the latest available from the official website.

{{< figure src="bios.webp" alt="ASUS BIOS shipped with unstable AGESA version.">}}

Turns out they shipped a release candidate, not the final release of the AGESA firmware.
Their BIOS _was not_ marked as experimental either.
Somehow they did an _ooopsie_, but luckily it was quickly remedied, and it didn't cause any issues for me.

But from that point onward, I paid much closer attention to BIOS updates.
After a few weeks from their release, I'd check Reddit to see feedback, and most of the time you see threads full of
people regretting their upgrades, or otherwise complaining.
And you can't really tell for sure, because there's always mixed reviews, some say it works fine, others say it causes
POST issues[^4], or blue screens[^5], or even bricks[^6].
You can find many examples just by looking them up.

Fortunately I did not have the X3D CPUs and wasn't as desperate to update, because if you didn't know, ASUS's bad BIOS
had wrong voltage settings that fried X3D CPUs[^7]!
In damage control mode, those versions were scrubbed off the website and quickly replaced.

The last stable BIOS I had for quite a while was **1709** from October 2023.
It did not fix *any* of the issues I've been having, but I was able to boot with 64GB in EXPO mode and did not suffer
from random reboots _(foreshadowing)_.
But there was another reason I chose to stay on this version: ASUS **disabled rollbacks** for earlier versions starting
from the next one, meaning I could not use the flash utility to go back to 1709 if an update causes me problems.
Most of the updates were related to compatibility with newer chips as well, so all-in-all, not that relevant to me
anyway.

Let me take a moment to reiterate: one of the most _"premium"_, and expensive motherboards comes with flaky BIOS updates
that can ruin your day any time, and for some unknown reason they don't offer a hardware failsafe / dual BIOS.
My previous motherboard, the Fatal1ty X99X Killer, along with *many* others, had BIOS select switches[^8], which was a
simple physical switch on the motherboard circuitry that allows you to change between two BIOS chips.
If you mess up, you could easily switch to the other one while you fix the issue.
Now?
Well you *technically* can use the BIOS FlashBack™[^9] feature to overwrite the BIOS without needing a working POST,
but it's not as convenient, and definitely does *not* provide you the same peace of mind.
What would've cost you to offer me an extra BIOS chip?
Why are you skimping on something so sane and trivial?
It's almost like they *want* you to brick your system.

## The QVL RAM Attempt

Remember the asterisk next to the RAM in the specs of the PC?
Initially I had a set of Corsair Vengeance, and not even high frequency ones, just 5600MHz ones.
At any rate, they were *not* on the motherboards QVL, and I wanted to give the benefit of the doubt, so when a friend
wanted to upgrade to DDR5 as well, I made him a good deal: I'll give you my Vengeance sticks and a few extra cash,
you buy me some RAMs on the QVL list.

Do you think it made any difference?
No, of course not.
But it was worth a shot.

## The Triple Monitor Sleep Freeze

We're in late 2024 now, and after playing around with a NixOS VM, I finally decided to make the switch away from Arch
Linux _(btw)_ and install NixOS on bare metal.
Everything went well, I installed my dotfiles, but then I encountered a brand-new bug: my PC would completely freeze
if I tried to suspend.
It took me the entire afternoon to debug, and I found that the bug only triggered if I had three monitors plugged in.
If I had two, in any combination, it worked as normal.

Was this my fault?
Was it some kernel or driver in NixOS that differs from my Arch install?
I couldn't fix it.

But months later, I encountered an article by nyanpasu64 describing both the issue and offering a solution[^11].
I can confirm this no longer is an issue with kernel 6.14!
If you're reading this, thank you so much for your efforts!

Do you know what I had to do to work around this in the meantime?
Physically unplug one monitor before suspending, and plugging it back in after waking up! 

## Random Reboots

Since a few months, I started experiencing random reboots.
Absolutely no kernel logs whatsoever, simply a black screen as if somebody pressed my PC's reset button.
And unless I did a cold power cycle afterwards and continued in the rebooted state, GPU performance in my VM would also
plummet sometimes, and the system would be overall more prone to resets.

They happened every few weeks, but weirdly enough, *never* when I was using my VM, only when doing light workloads on
the host, such as web browsing, code editing, etc.
When it did happen though, wait for the two-minute reboot, shut down gracefully, wait for another two-minute boot, and
go about your day.

As time went on, they got more and more frequent.
The last few kernel updates were the worst, sometimes not even lasting 30 minutes of boot time before crashing.
What was causing this?
I was sure it was at least partially a software issue, since they differed depending on what flake lock I was on.

Once, it managed to do the reboot *smack-dab in the middle of a Git squash*, and I had to waste time digging through
ref-logs to fix it, as I found myself in a weird, phantom detached state, almost causing me a day's worth of progress.

I even bit the bullet, and installed the latest BIOS, knowing I couldn't go back if it had problems.
It did not have any effect.
No sorry, it did not have any _positive_ effect, but it did make the reboots happen on the previously stable kernel
version.

By this time I had, quite understandingly, lost my patience.
I started angrily scouring the web for answers.
I found another blog post describing my exact symptoms[^12], and it suggested that the issue was the very optimistic
reported max frequency of the CPU.
I checked and indeed, it showed the max frequency of **5.85GHz**, even though it should Turbo Boost up until 5.7GHz
according to specs.
It seems this is *technically possible* for CPU spikes, if you run it very cool[^13], but I was having none of that.
Limit to 5.45GHz and pray; alas, it was all for naught, the reboots still happened.

The light at the end of the tunnel presented itself when I stumbled across people mentioning disabling the
Global C-States in the BIOS[^14], which normally, you do _not_ want to do because it makes your CPU less power efficient.
In a nutshell, C-States allow your CPU to power down unused cores when it idles.

This is just speculation on my part, but it seems that *something* in the AMD hardware-software stack combo is causing
core sleeps to trigger a hardware failsafe that reboots the entire system.
It at least explains why there were never any errors in the kernel logs, the OS didn't get the chance to realize it was
dead, the reset happened at a much lower hardware level.

Anyway, disabling the Global C-States fixed my random reboots.
I was able to be on the latest kernel with all my three monitors, with repeated suspend cycles, without any crashes or
hangs, at the cost of my cores never going below 2.6GHz _(compared to the usual 400-500Mhz)_.

## Conclusion and Acknowledgements

Fortunately I have now resolved the issues.
But this was definitely the _worst_ experience I had in all my life with any piece of hardware, ever.
Imagine something like this happening to someone less technical, not a great look.

I am disappointed at AMD, because they had the opportunity to be pro-consumer, to be different, but they ended up taking
shortcuts, having many more issues on Linux than previous generations, and also jumping on the AI hype train instead of
getting their ducks in a row.

The lessons learned was that I shouldn't buy a whole new system so close to launch, and that nowadays, expensive items
no longer correlate with an increase in their quality: they just don't make 'em like they used to.

All that being said, I will continue to recommend AMD for the time being, because Intel did even worse stuff: my CPU
indeed rebooted a lot, but at least didn't have permanent hardware faults [^15] that could fry itself outright[^16].
While being a bad first batch is inexcusable, and early adopters shouldn't be beta testers, overall people seem to have
a good experience with AM5, and after tinkering with it for two years, so do I.
My sample size of _n=1_, paired with the lack of other choice, can convince me to give them another, but much more
prudent chance in the future.

However, I cannot say the same thing about ASUS.
They exhausted any trust or benefit of the doubt I had in their brand.
Their almost flagship model gave me the worst experience of any motherboard I've interacted with ever.
Firmware updates and tweaking settings felt like defusing bombs, online forums were filled with frustration from
customers.

I would like to thank the entire community for sharing their problems, tweaks and solutions online.
Without you, I would've pulled off a lot more hair.
I also want to thank myself for installing NixOS, because having the ability to bisect kernel updates and seamlessly
rollback when having issues was an absolute godsend.

I hope you enjoyed the tales of my suffering, and that you had a better experience than me on AM5.

### Bonus: The BIOS Settings Cheat Sheet

For posterity, and for my own sake, I noted down the changes I made to my default ASUS X670E-HERO BIOS settings.
These work for me, might not work for you, not all of them might be necessary, some are unrelated to this article, but
rather preferences for my specific setup.
Consider yourself disclaimed, but here they are:

**Extreme Tweaker**

- AI Overclock Tuner: _Auto → EXPO II_
- GPU Boost: _Auto → Manual, 2200_
- Precision Boost Override:
  - Precision Boost Override: _Auto → AMD Eco Mode_
  - AMD Eco Mode: _Auto → cTDP 105W_
  - CPU Boost Clock Override: _Auto → Enabled (Negative)_
  - Max CPU Boost Clock Override(-): _0 → 400_
  - Platform Thermal Throttle Limit: _Auto → Manual, 80_
  - Curve Optimiser
    - Curve Optimiser: _Auto → All Cores_
    - All Core Optimizer Sign: _Positive → Negative_
    - All Core Optimizer Magnitude: _0 → 10_

**Advanced**

- PCI Subsystem Settings
  - Resize BAR Support: _Enabled → Disabled_
  - SR-IOV Support: _Disabled → Enabled_
- USB Configuration
  - Legacy USB Support: _Enabled → Disabled_
- SATA Configuration
  - SATA Controller(s): _Enabled → Disabled_
- Onboard Devices Configuration:
  - PCIEX16_1 Bandwidth Bifurcation: _Auto → PCIEx16_
  - WiFi Controller: _Enabled → Disabled_
  - Bluetooth Controller: _Enabled → Disabled_
  - LED Lighting in Sleep: _All On → Aura Off_
  - ASM1061 Configuration:
    - ASMedia Storage Controller: _Enabled → Disabled_
- NB Configuration
  - Primary Video Device: _PCIE Video → IGFX Video_
  - Integrated Graphics: _Auto → Force_
  - UMA Frame Buffer Size: _Auto → 4G_
- AMD CBS
  - Global C-state Control: _Auto → Disabled_
  - IOMMU: _Enabled (by default, verify)_
  - DDR Options
    - DDR Memory Features
      - Memory Context Restore: _Auto → Disabled_

[^1]: https://www.howtogeek.com/what-is-ddr5-memory-training/
[^2]: https://community.amd.com/t5/part-recommendations/amd-radeon-rx-7900-xtx-official-amd-statement-for-customers/m-p/573646
[^3]: https://community.amd.com/t5/pc-graphics/rx-7900-xtx-idle-power-usage-100-watt-on-dual-monitor/m-p/593758
[^4]: https://reddit.com/r/ASUS/comments/18kjbzu/has_anyone_tested_the_new_1807_bios_on_x670ee_mobo/
[^5]: https://reddit.com/r/ASUSROG/comments/1fs24ch/x670ee_bios_2403/
[^6]: https://reddit.com/r/buildapc/comments/13fy4gv/updating_the_bios_on_my_asus_motherboard_killed/
[^7]: https://reddit.com/r/Amd/comments/12uvcsm/asus_are_hiding_something_big_re_burning_7000x3d/
[^8]: https://download.asrock.com/Manual/Fatal1ty%20X99X%20Killer.pdf _(see page 26)_
[^9]: https://www.asus.com/support/faq/1038568/
[^10]: https://github.com/gnif/vendor-reset
[^11]: https://nyanpasu64.gitlab.io/blog/amdgpu-sleep-wake-hang/
[^12]: https://hjr265.me/blog/strangest-amd-7950x-bug/
[^13]: https://www.techpowerup.com/298883/amd-ryzen-9-7950x-boosts-to-5-85-ghz-only-if-you-can-keep-it-under-50-c
[^14]: https://reddit.com/r/AMDHelp/comments/10o6iqp/ryzen_7950x_random_rebooting/
[^15]: https://www.pcworld.com/article/2415697/intels-crashing-13th-14th-gen-cpu-nightmare-explained.html
[^16]: https://youtu.be/OVdmK1UGzGs
