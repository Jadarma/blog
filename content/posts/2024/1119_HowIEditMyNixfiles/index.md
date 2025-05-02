---
title: 'The Unnecessarily Complicated (But Delightfully Convenient) Way I Edit My Nixfiles'
description: 'Showcasing some helper scripts for a decent and isolated development experience when working on your NixOS configuration flakes.'
date: 2024-11-19
thumbnail: editor.webp
category: 'technology'
tags: [ 'nix', 'linux' ]
---

As I was messing about in my NixOS VM, tweaking my little flake experiment, I found myself wondering how I can improve
my development experience.
What started as a _"Could I?"_, turned into _"Should I?"_, and finally settled on _"Eh, Why Not?"_.

<!--more-->

## How I Got Here

I'm pretty new to Nix, and have a lot of stuff going on my main Arch PC that I didn't want to throw out until I had a
perfect replica.
So naturally, I made myself a VM _(with VFIO)_ and tasked myself with achieving feature parity of my Arch dotfiles in
NixOS.
This VM has been pretty much my daily driver for the last couple of months, so overall I have to say I'm pleased.
There's many open questions about _when_ I'll actually approve the big migration, but I digress.

I set up NixOS with flakes, hosted on GitHub, all the things you'd expect from a typical setup.
But, starting from scratch, I needed a nicer way to edit multiple files.
So it was obvious, time to set up an IDE!

It's no secret I love my IntelliJ, and there's even a nice [nix-idea plugin](https://github.com/NixOS/nix-idea) I've
used with moderate success.
But I wanted to start small, and from what I gather, there's much better Nix support in terminal text editors, which I
admire, but can't be bothered to learn.
So, that left me with my most dreaded thought: _having to use VSCode…_

## Loving To Hate VSCode

_"It's just a VM, would it hurt to try?"_ I thought.
And indeed, I could not argue against it.
So I compromised and installed [VSCodium](https://github.com/VSCodium/vscodium) instead.

But, because I love to hate on VSCode, and because I wanted to play with Nix goodies, I set myself a challenge to
isolate it in the depths of my `/nix/store` and only allow it to be used for this purpose:
nicely editing my Nix files.

The easiest method is to just:

```shell
nix-shell -p vscodium --run codium "$NIXFILES_REPO"
```

But that's a bit inconvenient, let's do something fancy with development shells.

```nix
{ # Rest of flake.nix...
  devShells.x86_64-linux.default = 
    let
      pkgs = import nixpkgs { system = "x86_64-linux"; }; 
    in pkgs.mkShell {
      packages = with pkgs; [ vscodium ]
    };
}
```

Now I can get the IDE in the path only when I `nix-develop`.
But, this is just the binary, what I needed were configs.

Here, the luck started to pile on, because:
- I could store any IDE config in VCS via `.vscode/settings.json`.
- I learned I can install extensions programmatically via Nix.

So, I did just that, added my desired settings, got my favorite theme, and configured the Nix integration:

```nix
{ # Rest of flake.nix...
  devShells.x86_64-linux.default = 
    let
      pkgs = import nixpkgs { system = "x86_64-linux"; }; 
    in pkgs.mkShell {
      packages = with pkgs; [
        nixpkgs-fmt
        nixd
        (vscode-with-extensions.override {
          vscode = vscodium;
          vscodeExtensions = with vscode-extensions; [
            equinusocio.vsc-material-theme
            equinusocio.vsc-material-theme-icons
            jnoortheen.nix-ide
            mkhl.direnv
            timonwong.shellcheck
          ];
        })
      ];
    };
}
```

Now all I needed for my development environment was conveniently isolated from the rest of my system.

## Some QoL With Direnv

While `nix develop` is nice, I have to call it manually, and then it drops me in Bash, which I don't have configured
because I'm a ZSH enjoyer.
Not a problem, this is where [direnv](https://github.com/direnv/direnv) comes in, or more specifically,
[nix-direnv](https://github.com/nix-community/nix-direnv).

After I added it to my config, all I had to do was:

```shell
echo 'use flake' > .envrc
direnv allow
```

And now the dev shell automatically activates and is loaded in _my_ shell session as soon as I `cd` into my repository.
Neat!

## Some More QoL With Just

I have also seen many recommend [just](https://github.com/casey/just) as a mini build tool, so I decided to give that a
try as well.
It's not much, but it's a little more convenient, not because I can't remember the command but because I'm too lazy to
type it.
My favorite use-case:

```justfile
rebuild TYPE="switch":
    sudo nixos-rebuild {{TYPE}} --flake .#
```

Much nicer to type `just rebuild` when I want to update my system.
And when I need to, I can, without loss of generality, `just rebuild test` or `just rebuild boot` too!

## Getting Even Lazier, But Learning Helpful Nix

This is the point where it started getting a bit ridiculous.
Every time I booted up the VM, I found myself doing the same things:

- `Super + Enter` to bring up a terminal.
- `cd ~/repo/nixfiles`
- `just code`

_"There's got to be a better way!"_

So let's automate it with a "simple" script:

```shell
#!/usr/bin/env bash

# Get the location of the nixfiles dir.
# In order or priority:
# - "$NIXFILES_DIR"
# - "$XDG_REPO_DIR/nixfiles"
# - "~/repo/nixfiles"
XDG_REPO_DIR="$(xdg-user-dir REPO)"
NIXFILES_DIR="${NIXFILES_DIR:="${XDG_REPO_DIR:-"$HOME/repo"}/nixfiles"}"

if [ ! -d "$NIXFILES_DIR" ]; then
   >&2 echo 'Nixfiles dir not found!'
   exit 2
fi

# Check that direnv was allowed, otherwise we do not have the `use flake` which provides VSCodium.
if [ "$(cd "$NIXFILES_DIR" && direnv status --json | jq '.state.foundRC.allowed')" != '0' ]; then
   >&2 echo "Direnv for $NIXFILES_DIR must be allowed first."
   exit 3 
fi

# Start the editor.
# Ensure the script is run from a ZSH interactive shell, otherwise the direnv won't load.
zsh -ic "cd $NIXFILES_DIR && just code"
```

That's quite a verbose way to automate three lines of shell, but it has a reason to exist, trust me!
For now, all that matters is I can just call this script and have it automatically open up the IDE from within the
`direnv` shell, without having to `cd` anywhere, and without even needing to open a terminal
_(the script can be bound to a shortcut, for example)_.

Now to make this script available to my path, we can make use of `pkgs.writeShellApplication`, which is awesome.

```nix
{ pkgs, ... }: {

  # Create the nixfiles script.
  home.packages = with pkgs;
    let
      nixfiles = {
        name = "nixfiles";
        runtimeInputs = [ jq nix-direnv xdg-user-dirs zsh ];
        text = builtins.readFile ./nixfiles.sh;
      };
    in
    [ (writeShellApplication nixfiles) ];
}
```

With this simple snippet, the script is automatically handled by Nix, and the script itself has all of its dependencies
_(the `runtimeInputs`)_ called directly from the Nix store and are not required to be in the path.

**NOTE:** The way it works, is that Nix makes a fancy script header, and then appends the script `text` to it.
Therefore, the shebang in my script is _a LIE_!
It actually ends up as a simple comment, but I keep it there to aid with using it directly from the IDE.

## Turning The Script Into an Application

So, come to think of it, I said I did not want my VSCode to exist outside of this one project.
But that doesn't mean I don't want an application for it!

Because I now had a script that magically spits out an IDE instance, I was one config away from calling it good enough:

```nix
{ ... }: {
  # Create a desktop entry, for convenience.
  xdg.desktopEntries.nixfiles = {
    name = "Nixfiles";
    genericName = "NixOS Configs";
    icon = "nix-snowflake";
    comment = "Open a code editor to edit the system's Nix configs.";
    categories = [ "Application" ];
    exec = "nixfiles";
    terminal = false;
  };
}
```

This adds a `.desktop` entry for the `nixfiles` script, with a cute Nix icon.
Which means that now, when I open up my VM, to make any edits, I can just open it from my `wofi` launcher.

## Conclusion

The editor looks like this:
{{< figure src="editor.webp" alt="A screenshot of my editor.">}}

To sum up what happened here:
- I made my configs also define a reproducible dev environment for editing themselves.
- Said dev environment is isolated from the rest of the system.
- I created a desktop shortcut, that runs a script, that launches the project.
- In the end, it's like my OS has a dedicated application for its own management.

This has been a fun experiment, a path blindly carved that ended up in the right place.
Did I overcomplicate it?
Perhaps.
But will I keep using this?
Yes, I've gotten used to this workflow.

You can take a look at my [nixfiles](https://github.com/Jadarma/nixfiles), and for your convenience, here are the
relevant files for this article _(pinned to the time of publishing)_:
[`flake.nix`](https://github.com/Jadarma/nixfiles/blob/75a8886958e098a878f0d915f81a129dcf261d87/flake.nix#L56),
[`settings.json`](https://github.com/Jadarma/nixfiles/blob/75a8886958e098a878f0d915f81a129dcf261d87/.vscode/settings.json),
[`justfile`](https://github.com/Jadarma/nixfiles/blob/75a8886958e098a878f0d915f81a129dcf261d87/justfile),
[`direnv`](https://github.com/Jadarma/nixfiles/blob/75a8886958e098a878f0d915f81a129dcf261d87/modules/home/direnv/default.nix),
[`nixfiles`](https://github.com/Jadarma/nixfiles/blob/75a8886958e098a878f0d915f81a129dcf261d87/modules/home/scripts/nixfiles/default.nix).
