---
title: 'Please Stop Updating Yourself'
description: "A rant about self-updating software, why this never should have existed, and why it's probably 
Microsoft's fault."
date: 2024-03-31
category: 'technology'
tags: [ 'rant', 'software' ]
---

Self-updating software is sometimes viewed as a feature, but to me, it's just annoying.
A rant about this practice and a plea to stop this trend.

<!--more-->

### Why Self-Updating Software Sucks

When it comes to operating systems, I am a jack of all trades.
I use Linux on my main machine, a MacBook for work, and a Windows VM for gaming.
As such, I am no stranger to the many ways of packaging and managing software.

Let me start by listing the disadvantages from my point of view.
These make most sense from the perspective of a Linux/macOS user.

1. **What's the point of packaging?**
   If you install a package, but then that software updates itself, what's the point of then updating the package as
   well?
   _(Looking at you especially, Discord!)_
2. **Updates can't work sometimes!**
   The usual way to self-update is to download some binaries and dump them in a well-known filesystem path.
   But what if you can't do that because you are in a container?
   Pressing the _Update_ button in a read-only AppImage, FlatPack, or Snap _(ew)_ would just lead to an error.
3. **Annoying Redundant UI!**
   If the previous point applies, then you will always see that prominent update button, which becomes useless.
   And hey, I'm not against the program letting me know there is an update, but I wanna handle it myself, show me the
   minimum amount I need to know.
4. **What About Rollbacks?**
   Your app auto-updated itself.
   You experience some issue that others aren't.
   Maybe it's something on your end, but you'd like to check.
   Too bad, the app can update, but almost never downgrade as well, more annoying stuff for you to deal with.
5. **Muh Reproducibility!**
   If you want to achieve a declarative configuration of your operating system _(check out [NixOS](https://nixos.org/))_
   then you probably have some sort of dependency pinning.
   But that all is useless if what your package contains is just the bootstrap code that downloads some latest binary
   off
   the internet _(looking at you again, Discord)_.

### The Exceptions

Let's not deal in absolutes.
There are situations where I do see the case for self-updating software being sensible!
Well, that's kind of a misnomer, because what I actually refer to here is a more scoped package manager, or launchers.

For example, [MultiMC](https://multimc.org/) is a Minecraft launcher that allows you to have multiple installations of
different versions, or [JetBrains Toolbox](https://www.jetbrains.com/lp/toolbox/) which can manage multiple
installations of IDEs in case you need older versions for compatibility of a tricky legacy project, or want to
experiment with an EAP version without affecting your main, stable one.

For browsers or IDEs or other such software with its own subset of add-ons, plugins, what have you, it is reasonable to
let that software manage them separately.
The plugin API changes separately from the software itself, so it shouldn't be a problem.

Regarding content libraries, I would expect something like Steam to manage my games library itself.
It can take care of all the cloud sync, updates and patches, and DRM.
From the perspective of an operating system user, all I want to say is `install steam` and I know that I am ready to
game whenever and whatever I want.

In such cases, not only do I see the benefit, but I actively want it as a feature!
It's super useful, and convenient!

The only thing I would add here: _Stop Allowing the Software To Update Itself!_
Because otherwise, we get into the same annoyances mentioned earlier.
I want my system to manage the version of the software, it should have no business updating itself, its job is to manage
whatever other software it manages, simple-as!

Self-evidently, package managers are exempt from that, they earn the right of updating themselves
_(`pacman`, `brew`, etc.)_.

### Who's To Blame

It would be a low-hanging fruit to go after the developers of the _(mostly JavaScript + Electron wrappers)_ software.
After all, dependency management is still an open question for the JavaScript ecosystem, only being surpassed in
insanity by Python libraries.

But no, they get a pass from me this time.
The developers chose this path for their convenience as well in some sense, but by far the biggest deciding factor was
UX.
Alas, not because _"The average user is not tech-savvy enough to keep their stuff up-to-date"_, but because
_"The average user runs Windows"_.

Microsoft Windows, the leading operating system of the 21st century, somehow managed to never incorporate a central
software repository.
I remember the ritual of having to visit countless websites to download installers every time I helped friends or
relatives upgrade their machines.
In time, the UX slightly improved with community efforts like [Ninite](https://ninite.com/), or
[Chocolatey](https://chocolatey.org/), anything but the goddamned Windows Store.
Okay, to be fair, there is [winget](https://github.com/microsoft/winget-cli) now, but it's too little too late.
The user-base was not _taught_ to use something like this.

### What Can Be Done?

First off, I want to make it clear that I am not delusional enough to expect the self-updating feature to disappear.
Many users need it, it suits their workflow, who am I to take things away from them.
But precisely because I advocate for users' freedom of choice, I plead: **make it a feature flag**:

- Enable it by default on the build targets that need it, like Windows, or non-`brew` MacOS targets.
- Leave it out for binaries meant to be repackaged, OR:
- Make the feature an opt-(in or opt) based on a user-defined config file, CLI argument, or environment variable.

This has advantages from all perspectives:

- The regular users don't care, they are not affected.
- The power users can get rid of stuff they don't need and stop complaining.
- 3rd party package maintainers will have an easier time if they don't need to account for the thing they're packaging
  mutating itself.

Perhaps one day!
