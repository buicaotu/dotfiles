# Dotfiles

This repository contains my dotfiles, managed with GNU Stow.

## What's included

- Neovim configuration
- Wezterm configuration
- Git configuration
- Github configuration

## Setup

1. Clone this repository:
```bash
git clone https://github.com/yourusername/dotfiles.git ~/.dotfiles
cd ~/.dotfiles
```

2. Use stow to create symlinks:
```bash
# For all configurations
stow */

# For specific configurations
stow nvim
stow wezterm
stow git
stow gh
```

## Directory Structure

```
dotfiles/
├── nvim/
│   └── .config/
│       └── nvim/
│           └── ...
├── wezterm/
│   └── .wezterm.lua
├── git/
│   └── .gitconfig
│   └── .gitignore_global
└── gh/
    └── .config/
        └── gh/
            └── config.yml
```

## How it works

GNU Stow creates symlinks from the parent directory of where you run the command. For example:

- When you run `stow nvim` from the `~/.dotfiles` directory, it will symlink the contents of `~/.dotfiles/nvim/.config/nvim` to `~/.config/nvim`
- When you run `stow git` it will symlink `~/.dotfiles/git/.gitconfig` to `~/.gitconfig`

## Adding new configurations

To add a new configuration:

1. Create a new directory in the root of this repo
2. Mirror the directory structure from your home directory
3. Run `stow <new-directory>` to create the symlinks

### Using common zsh

add the following line to your `~/.zshrc` to source a common zsh configuration file:

```bash
common_zsh=${XDG_CONFIG_HOME:-$HOME/.config}/zsh/common.zsh
[[ -f $common_zsh ]] && source $common_zsh
```
