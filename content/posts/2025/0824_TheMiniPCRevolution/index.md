---
title: "The MiniPC Revolution"
description: "Reasons why you should consider breaking your hardware up into MiniPCs."
date: 2025-08-24
series: 'homelab'
category: 'technology'
tags: [ 'hardware' ]
---

Over the past couple of years I've been experimenting with MiniPCs, and the more I do, the more I'm convinced this is
the future I want to invest in.

<!--more-->

## The Many Advantages Of MiniPCs

Before I ramble on about how great something I like is, first let me assure you that I know they're not perfect either,
and might not be what some people want.
Nevertheless, here are my own reasons and explanations for how I came to be swayed in this direction, why I think it's a
good idea, and why I would recommend this to others.

### Cheap and Replaceable

MiniPCs are all-in-one, factory built, shipped as-is products.
The converged supply chain and economy of scale usually leads to MiniPCs being cheap, or at least with very high bang
per buck all things considered.

However, because of these same reasons, they are usually not repairable, and theoretically produce more E-waste.
I don't worry about this too much: they are fully solid state machines, running on low power and low-ish temperatures,
thus making their rate of degradation much slower than some beefy machine churning 24/7.

### Small and Compact

It's called mini because it is.
These adorable devices don't take up space, and in a pinch, are portable as well!
If you need lots of computers around the house, this is the way to go.

Need a living room HTPC to browse the internet and such on a big screen at social gatherings?
Get a MiniPC and chuck it behind the TV.
No one will even notice it.

Have a small desk nook where you do some light work?
Connect the monitor, mouse, and keyboard to a MiniPC.
It looks like a dock, but it's actually the entire computer!

### Power Efficiency

Most MiniPCs are based on low-voltage hardware.
The power draw can vary in peak usage based on how beefy it is, but they are the kings of idle power consumption.
You can expect average power draws of 20-50W in usage and 6-12W in idle.

Put that in perspective with high-end machines with hardware concerned with performance and not power draw, that can
easily idle at 100W.

Things that need to run 24/7 but aren't actually in use 24/7 are great beneficiaries of running on MiniPCs.
And in the long run, your electricity bill will be lowered using several MiniPCs versus a big bad box.
If the actual price doesn't seem that much to you, at least take solace in knowing you're going greener and consume
less.
If that's not important either, then you're hard to please, aren't you?

How about we allow ourselves to ponder a little on the not so distant future?
The current hardware is generally still `x86_64`, but in future we'll have ARM, or dare I dream, RISC-V?
We'll get less power consumption for the same level of compute or more compute for the same level of power consumption.
Ok, Apple already has this with the M4s, and that's exactly my point, look how well it works!
And there's also a handful ARM based boards out there, it's just a matter of time till they reach general availability.

### Versatile Through Specializations

You cannot use a MiniPC do to everything, but everything you need to do can be done by a MiniPC.
By mixing and matching different types of MiniPCs, you can cover all your computing needs!

- **General Compute**:
    The first one you think of, run-of-the-mill MiniPCs are usually just this, laptop-grade hardware in custom PCBs in a
    different form factor.

- **Networking**:
    You can find MiniPCs with 4-6 ethernet ports too, making them an ideal platform to run custom firewalls, routers, or
    simply a personal VPN connected 24/7 to your network.
    They are more powerful and smaller than your average routers.

- **Network Storage**:
    You can get MiniPCs with 4-6 internal M.2 slots that are great for building a NAS with.
    That is, of course, if you don't need mass storage _(≤20TB)_, and you don't mind the higher cost per GB of flash
    storage.

- **Personal Cloud**:
    Take a beefy general compute MiniPC, install Linux on it, and make it a convenient container hoster.
    Storage? What for? We can keep that on the NAS. We just do compute here.
    If you're demanding and want resiliency too, why not get multiple computers and build a mini cluster?

- **Dammit Apple**:
    If you're like me and want your main station to be Linux, but also have apps and other use-cases that require macOS,
    good news, Apple makes MiniPCs too, and quite powerful ones at that.

### Monoliths Are Hard To Build

Let's imagine you want to build a homelab with the first four use-cases mentioned above.
You will need a motherboard with good I/O, an extra decent network card, a case with many drive bays for storage, lots
of RAM for ZFS, and the services you run, along with a CPU with enough PCI lanes and cores to keep up with all that.

Usually for this, consumer components don't offer _exactly_ what you need.
You might find yourself scouring the web for weird deals on Amazon or second hand markets.
Suppose you find everything, but they don't ship at the same time.
Suppose you made a mistake, and you need to return something but because you had to wait to find out about the
incompatibility, you're out of the return grace period.

Okay, maybe that's a little too contrived of an example, but the point I'm making is generally good hardware for a
single desktop to handle everything is hard to come by, and also not very lenient towards you having an easy time.

And I'm fairly certain you will get the same utility for a lower or equal price, with much less manual work needed, if
you shop for a few MiniPCs instead.

### No Need For Virtualization

Virtualization is amazing and useful, but also annoying.
That is not to say MiniPCs can't do it, in fact they make a good Proxmox host.
But if you use MiniPCs you don't *need* to use VMs in the first place.

For the NAS + Personal Services example, let us imagine we were on a monolith PC with TrueNAS on bare metal, and we
would like a VM for the media PC connected to a nearby TV, and one container to run Jellyfin.
We want them both hardware-accelerated, and we have two GPUs, great so… *WHOOPS!*
We can't pass both of them because TrueNAS insists on keeping one for the host, and it's really a pain to circumvent.

If instead we had a MiniPC being just a NAS, one being just a service host, and one being just an operating system for
the TV, we wouldn't need to even make any of these considerations.
Everything is already compartmentalized.

In a sense, _you_ become the virtualization host.
Do you need another VM? Buy a MiniPC and add it to the network.

### Avoiding Single Points of Failure

Imagine the next conversation when a friend comes to visit.

— Hey dude, I'm trying to use the bathroom but the light switch isn't working.

— Remember last week we were watching that movie on my living room PC thing?
  Well actually, the PSU just died couple days ago, I'm waiting for a replacement.

— That's unfortunate, but what's the connection?

— Oh yeah, my bad, those are smart home bullshit. The switch doesn't actually go anywhere it sends messages to my
  HomeAssistant, which then is supposed to tell the bulbs to turn on.

— Home what? Oh…, cool I guess? So why ain't it working?

— That used to run on the PC, so while that's down I can't use it.

— So you mean to tell me you've been using your torch to take a shit this last week because your light bulbs don't work
  without the PC you watch Netflix on?

— Yep… uh… *yep*. I guess in hindsight I would've done it differently.

There's a reason why people recommend getting a separate Raspberry Pi for that!
Hardware failures are unpredictable and unavoidable.
But at least you should try and minimize the inconvenience such events bring.

### Less Stressful, Fun To Tinker

This one is simply a personal observation on how I've had a mentality shift working with MiniPCs.
Because of the decentralized, isolated nature of their hardware within my home network, I am generally much braver when
tinkering with it.

Taking the container service compute out of my NAS and into a separate MiniPC allowed me to confidently do whatever to
it, because it's separate.
I couldn't accidentally screw up my NAS by working on the homelab server.
Even if that was technically true in a virtualized environment inside the NAS, this is about subjective feeling.
This placebo of bravery and confidence is very fun and rewarding.

Same thing with having the M4 Mini on my second desk.
In the rare event that I do something that temporarily incapacitates my main PC, I am at least relieved I have a backup
computer ready to use if I have important tasks and responsibilities.

## Conclusion

MiniPCs are a _great idea_ if you're just looking into starting a homelab.
They scale with you, around you, and aren't a big upfront investment.

It's indeed a far cry from the initial fantasies I had when first getting into homelabs and self-hosting, namely big
beautiful racks _(of server hardware!)_ I'd hide locked in a ventilated closet.
I, for one, am extremely satisfied with the modest but very useful setup I ended up having.

There are many resources and communities online you can look up if you want to learn more.
You should give it a try!
