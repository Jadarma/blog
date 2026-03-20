---
title: "Unified Modules For Your Nixfiles"
description: "How to write dotfile modules for NixOS, nix-darwin, and Home Manager, with an easy mental model and no external dependencies."
date: 2026-03-20
thumbnail: thumb.webp
category: 'technology'
tags: [ 'nix', 'tutorial' ]
---

Life was easy when you first started out on NixOS with a single machine.
Then you decided you want to have your configs available for macOS as well.
Then you wanted to support an arbitrary number of hosts.
Then you wanted to group modules more naturally.
After some trials and many errors, here is where I ended up to achieve all three.

<!--more-->

# Why I Don't Like the "Standard" Method

The typical structure of most starter templates[^3] use something like this:

```text
nixfiles
├── modules
│  ├── home
│  │  ├─ hyprland.nix
│  │  ├─ gpg.nix
│  │  └─ default.nix
│  ├── nixos
│  │  ├─ hyprland.nix
│  │  ├─ gpg.nix
│  │  └─ default.nix
│  └── darwin
│     ├─ homebrew.nix
│     ├─ gpg.nix
│     └─ default.nix
└─ flake.nix
```

The modules are split by type, not feature.
This works, but it introduces annoyances when you need to combine them.

If you need both a `home.nix` and `configuration.nix` module for the same feature, these files will be far apart and not
convenient to casually browse through the project tree view.
Imagine you have lots of them, and with potentially duplicated meta-structure
_(subdivision by programs, services, or other custom taxonomies you might use)_.

Sometimes you need modules to cooperate together _(e.g.: to set up Hyprland, you'd need `home.nix` to manage the config,
but also a `configuration.nix` for enabling Wayland, setting up desktop portals, etc.)_.
Declaring them is not a problem, but you will need to import _(or enable)_ both separately, using one without the other
would be misconfiguration.

Speaking of imports, the typical method is to use directories with hardcoded `default.nix`-es importing the rest of the
directory in bulk.
Also works, but it's manual work, you can accidentally forget things when you refactor.

Now, I critique it, but it also works great for the absolute beginnings, when you dip your toes into how nix modules
work.
That being said, I consider it a stepping stone, because I found myself annoyed enough of the drawbacks to consider
alternatives.
The realization that sealed the deal was when I was trying to point a friend to one of my configs as a reference, and I
went: _"Yeah, but it's system module, so go there… no wait…, ahh I think that was a HM thing, scroll up to where it says
home… yeah now expand the same path for the module, more… uhh… where did I put that again?!"_

# Goals and Criteria

There is no such thing as a silver bullet, and preference weighs in heavily to something as personal as your dotfile
collection.
This is how I do it, and here are the things I wanted from it.
If you also align with these goals, it might work for you too:

- **Only for Dotfiles** —
  This module is only meant to handle dotfiles, meaning configs for personal computers.
  While some prefer to have God-Flakes that handle everything from microcontrollers to servers, I prefer having those
  separate.

- **No Standalone Home Manager** —
  Probably a deal-breaker for some, but it's a no-brainer for me.
  My systems will always be running either NixOS or macOS, there is no target where I would ever need a standalone HM
  installation.

- **Single User** —
  The dotfiles are _mine_ and will be running on _my_ personal devices, which will never share another user.
  A significant other is significant enough to merit their own machine, and kids are too stupid to trust with your own
  hardware anyway.

- **Opinionated Modules** —
  You already have customizable general modules that let you tweak every detail of the installation.
  We do not want to reinvent wheels, we want to design specific frames to mount them on.
  The goal here is to have meta-modules that, if enabled, handle those choices for you.

- **Contextual Behavior** —
  Some things need to behave differently depending on the host platform.
  Therefore, it must be easy to define things that only apply on NixOS, things that only apply on macOS, and things that
  apply on both with subtle differences.

- **Well-Structured Source** —
  In time, you will accrue lots of modules.
  For ease of maintainability, there should be no cognitive effort in locating where in the repo the configurations for
  any particular module live. 

- **No (Extra) External Dependencies** —
  There are many examples of people building utilities and conventions for such things, with a wide range of complexity,
  from [Snowfall](https://snowfall.org/guides/lib/quickstart/) to
  [Dendritic Nix](https://dendrix.oeiuwq.com/Dendritic.html).
  I want none of that, because I do not want to depend on non-essential external dependencies, I want a DIY solution
  that I am in full control of and learn more about Nix as I go.
  I just want a convenient way to use the big three together: nixpkgs, Home Manager, and nix-darwin.

# Visualize The End

A good starting point is to visualize the way you want to use the modules.
The end goal for me was to have a simple attribute set in my `configuration.nix` that works on any system, kind of like
what the basic out-of box NixOS experience is like.

I want my `configuration.nix` to remain succinct, so that I have a high-level overview of what is going on my system.

For example:

```nix
{ pkgs, ... }: {
  imports = [ ./hardware-configuration.nix ];
    
  nixfiles = {
    enable = true;
    user.name = "dan";

    development = {
      enable = true;
      containers.enable = true;
    };
        
    programs = {
      defaultCli.enable = true;
      defaultGui.enable = true;
      steam.enable = true;
    };
        
    # ...
  };
}
```

Everything under `nixfiles` represents my custom configs, with options defined by me, that abstract the common stuff
that I might want to toggle on and off.

Many programs, like the terminal and many CLI tools, I usually want to enable everywhere.
It would be nice to have a meta-option, like the `nixfiles.programs.defaultCli.enable` that would add all of them for me
instead of me having to do it one-by-one.

Others, like `nixfiles.programs.steam` act like a module for a single program, but it doesn't _need_ to be!
I chose this example because whenever I enable Steam, I also want some utilities that go with it — like `gamescope`,
`protonup`, and `MangoHud` — that I would never manage or enable by themselves.

In essence, I am building my own DSL that makes sense for me.
You would do it completely differently, I'm sure.
But that's the beauty of the versatility that comes with DIY.

# File Structure, Conventions, and Boilerplate

The file structure I use looks like this:

```text
nixfiles
├── modules
│  ├── bat
│  │  ├─ common.nix
│  │  └─ home.nix
│  ├── gpg
│  │  ├─ common.nix
│  │  ├─ darwin.nix
│  │  ├─ home.nix
│  │  └─ nixos.nix
│  ├── hyprland
│  │  ├─ common.nix
│  │  ├─ home.nix
│  │  └─ nixos.nix
│  ├─ common.nix
│  ├─ darwin.nix
│  └─ nixos.nix
└─ flake.nix
```

There are up to four main files for each module:

- `common.nix` is imported on all systems and is mainly used as an analog of `default.nix`, except it doesn't handle
  imports, but declaring shared module options and assertions.
- `nixos.nix` is only imported by NixOS systems, if it exists.
- `darwin.nix` is only imported on macOS systems, if it exists.
- `home.nix` is imported as a HM module on all systems, if it exists.

The top-level `nixos.nix` and `darwin.nix` are the modules you would pass to the `nixpkgs.lib.nixosSystem` and
`nix-darwin.lib.darwinSystem` functions in your `flake.nix`.
They are responsible for importing all other submodules.

The directory structure follows the option path, so it's easier to locate when you want to make changes.
You know that `nixfiles.programs.git` option was declared in `modules/programs/git/common.nix`.

The only difference between this `home.nix` and regular ones is that instead of reading from the user-specific `config`
that HM usually uses, we instead use `osConfig`[^4], which reads the module options of the system, because that's where
`common.nix` operates.
So for example, Git's `home.nix` would build the config by checking `osConfig.nixfiles.programs.git.enable`.
This is why I mentioned my dotfiles are single-user, because the `osConfig` is system-wide.

Many modules will be entirely shared via HM anyway, and would only contain a `common.nix` for the options and a
`home.nix` for configuration, like the `bat` example above.

# Automatic Imports

On a more complex module we would have up to four files we need to import, but that is tedious work and prone to errors.
I know everyone has, at least once, wondered why their config they copy-pasted wasn't working, only to realize they
forgot to actually import it.

But since we have a naming convention, and our main module is a God-module which must import everything, we can script
the imports instead of adding them manually:

```nix
lib.pipe ./. [
  (lib.filesystem.listFilesRecursive)
  (lib.lists.filter (lib.strings.hasSuffix "common.nix"))
  (lib.lists.filter (path: path != ./common.nix))
]
```

Hopefully the snippet is self-explanatory.
We list all files in our module directory _(`./.`)_ recursively, keep only those that end in `common.nix` ignoring the
file we are already in to prevent recursion.

Then the main `common.nix` is responsible for importing all the other `common.nix` as well as the `home.nix` files:

```nix
{
  imports = lib.pipe ./. [
    (lib.filesystem.listFilesRecursive)
    (lib.lists.filter (lib.strings.hasSuffix "common.nix"))
    (lib.lists.filter (path: path != ./common.nix))
  ];

  options = {
    nixfiles = {
      enable = lib.mkEnableOption "Whether to enable the Nixfiles module.";
    };
  };

  config = lib.mkIf config.nixfiles.enable {
    # Alternatively, `home-manager.sharedModules`, but I like to be specific.
    home-manager.users."${config.nixfiles.user.name}".imports = lib.pipe ./. [
      (lib.filesystem.listFilesRecursive)
      (lib.lists.filter (lib.strings.hasSuffix "home.nix"))
    ];
  };
}

```

While the main `nixos.nix` and `darwin.nix` import all their respective system modules along with the `common.nix`:

```nix
imports = [
  home-manager.nixosModules.home-manager
  ./common.nix
] ++ lib.pipe ./. [
  (lib.filesystem.listFilesRecursive)
  (lib.lists.filter (lib.strings.hasSuffix "nixos.nix"))
  (lib.lists.filter (path: path != ./nixos.nix))
];
```

# Handling System-Specific Divergences

Some things need to be configured differently depending on the platform, that's why we have to _"unify"_ the modules in
the first place.
Here we use two techniques.

First, and easiest, is when they are system options:
- Everything that is system specific goes in `nixos.nix` or `darwin.nix`.
- Everything that goes for both _(very basic core options)_, can stay in `common.nix`.

For Home Manager though, we have a single `home.nix`, and here is where we get to script!

The trivial example is where we have a common config, and only a small part — like which specific package to use —
differs across platforms.
As an example, the `pinentry` program for the GPG module.
We can inline that distinction with a very simple `if` checking the `stdenv.hostPlatform`[^1]:

```nix 
services.gpg-agent.pinentry.package =
 with pkgs;
 if stdenv.hostPlatform.isDarwin then pinentry_mac else pinentry-gnome3;
```

If we need to define multiple options for each system, then we can make mini-configs and merge them.
This looks daunting at first, but it isn't all that bad, I promise:

```nix 
{ osConfig, lib, pkgs, ... }:
let
  common = {
    # Both
  };
  onDarwin = lib.mkIf pkgs.stdenv.hostPlatform.isDarwin {
    # Darwin-specific
  };
  onLinux = lib.mkIf pkgs.stdenv.hostPlatform.isLinux {
    # NixOS specific
  };
in
lib.mkIf osConfig.nixfiles.someModule.enable (
  lib.mkMerge [ common onDarwin onLinux ]
)
```

Hey, that looks pretty good, why don't we use them for system stuff too, and then only have `home.nix` and `system.nix`?
An excellent question with a disappointing answer: system modules are not the same, and `lib.mkIf` isn't magic.
All it does is replace the right-hand-side with an empty attr set if the condition is false.
But the option being declared, the left hand side, still must exist.
This is a bit outside the scope, but I want to provide a bit more context rather than
_"you're just not allowed to, OK?"_
Feel free to [skip](#handling-system-exclusive-modules) this explanation.

```nix
parent = lib.mkIf condition {
    childA = { /* ... */ };
    childB = { /* ... */ };
}
# This is equivalent to:
someOption = {
    childA = lib.mkIf condition { /* ... */ }
    childB = lib.mkIf condition { /* ... */ }
};
```

When Nix evaluates the module, `someOption.childA` and `someOption.childB` must exist as valid option definitions even
if they are not set, due to the way module options work in Nix.

Therefore, the following is _illegal_:

```nix
# Bad common code.
services.displayManager.autoLogin = lib.mkIf condition {
    enable = true;
    user = "john";
  };
```

The above would work on Linux, but still fail on macOS, because `nix-darwin` does not define the
`services.displayManager` option module, and therefore would fail at the configuration validation step.

Stuff like `environment.systemPackages` works in common module because both NixOS and nix-darwin define it the same.
They are still differing implementations under the hood, it's just a coincidence _(i.e.: convention)_ that they have the
same name.

This is the main reason we split system modules by files entirely: the intersection between the two platforms' module
systems is too small to be useful.  

# Handling System-Exclusive Modules

There are some features or functionality in your modules that can only apply to one system, so the _"unified"_ concept
doesn't really help.
But earlier in the convention we declared all such options in the common module, which would mean they are visible from
incompatible systems too!

Of course, one could define the options in only the `nixos.nix` or `darwin.nix` files
_(they are just modules after all)_, but that would break our previous convention of declaring options in `common.nix`.
I prefer not to do that, simply because I like having options documented separately and keep individual files shorter
and easier to parse with eyeballs.

Instead, we can use assertions[^2]!
There's no problem with having unusable options defined if they are not used, and this is, in fact, how Nixpkgs and
Home Manager handle it as well.

As an example where we do not want to game on macOS, we can assert the correct platform:

```nix 
{ config, lib, pkgs, ... }:
{
  options.nixfiles.programs.steam = {
    enable = lib.mkEnableOption "Steam";
  };

  config = lib.mkIf config.nixfiles.programs.steam.enable {
    assertions = [
      {
        assertion = pkgs.stdenv.hostPlatform.isLinux;
        message = "Steam is only configured for Linux gaming, but this is not a NixOS machine.";
      }
    ];
  };
}
```

Trying to evaluate a configuration with Steam enabled on macOS will error out with a useful help message. 

Assertions are very helpful, and you can also use them to ensure dependencies without enabling them by default in the
module _(e.g.: having the module of a GUI app fail the build if no desktop environment exists)_.

# Abstraction Example

Here's a more interesting example of a module that can make use of this abstraction: containers!
On NixOS, configuring a local container runtime for development with Docker is a straightforward system option, but on
macOS we need to do something different entirely, since we need a Linux VM.
Personally, I use [Colima](https://github.com/abiosoft/colima) to manage it on the macOS side, which is available on
Home Manager, but I don't want to use it on NixOS as well.

My module would look like this:

```text
nixfiles/modules/development/containers
├─ common.nix
├─ home.nix
└─ nixos.nix
```

In `common.nix`, I just declare an enable option so that I may toggle this from individual system configs.

```nix
{ lib, ... }:
{
  options.nixfiles.development.containers = {
    enable = lib.mkEnableOption "Containers";
  };
}
```

In `nixos.nix`, all we need to do is enable the Docker service and add our user to the group:

```nix
{ config, lib, ... }:
lib.mkIf config.nixfiles.development.containers.enable {
  virtualisation.docker.enable = true;
  users.groups.docker.members = [ config.nixfiles.user.name ];
}
```

In `home.nix`, we enable Colima if we are on macOS:

```nix
{ osConfig, lib, pkgs, ... }:
let
  onDarwin = lib.mkIf pkgs.stdenv.hostPlatform.isDarwin {
    home.packages = with pkgs; [ colima docker-client ];
  };
in
lib.mkIf osConfig.nixfiles.development.containers.enable (
  lib.mkMerge [ onDarwin ]
)
```

Yes, the `mkMerge` is extraneous in the above example but practice forward-thinking!
Remember this is a shared HM module, so this could also be a place to add convenience shell aliases or what have you for
both platforms if you want!

# Know When To Stop

When you hold a hammer, everything looks like a nail, but try to hold off and think what needs abstraction and what can
be a one-off file you import from a single system.

For example, on my main PC, I have a VFIO setup for gaming.
I *could* make a VFIO module and define some options, make it just generic enough for it to be reusable, but that is a
bit more complex because it is hardware-specific.
In the end though, how likely am I to have _two_ hosts that need VFIO?
Given the absolute state of the hardware market, very unlikely.
So that is not a unified module, just a `vfio.nix` located as a sibling file to the `configuration.nix` of the only host
that makes use of it, imported manually — keep everything pragmatic!

# Conclusion

I state again that this is not _THE_ way to do it, and I am by no means an advanced Nix user, but I learned a lot by
playing with this.

For me personally, it works quite well, and having used it for a few months I feel like this is pretty much going to be
my _"forever setup"_.
The structure I find organized, haven't found any limitations _(outside of those I specified I don't care about)_, and
I really am _not_ looking forward to refactoring my behemoth of a Flake again.

Feel free to take a gander at my [`nixfiles`](https://github.com/Jadarma/nixfiles) repo and explore it at your leisure,
and decide if it's something that might work for you!

[^1]: https://nixos.org/manual/nixpkgs/stable/#ssec-cross-platform-parameters
[^2]: https://nixos.org/manual/nixos/stable/index.html#sec-assertions-warnings
[^3]: https://github.com/Misterio77/nix-starter-configs/tree/8014a255025e5217482930b7b9531256f0bc8c99/standard/modules
[^4]: https://nix-community.github.io/home-manager/#sec-install-nixos-module
