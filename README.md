# Dotfiles

Dotfiles for configuring a developer environment on Macs (including M* arch) with ZSH and Homebrew.

## Requirements

- MacOS

## Installation

```bash
git clone https://github.com/robb-romans/dotfiles.git ~/dotfiles
cd ~/dotfiles
./setup
```

This will install all required dotfiles in your home directory as symlinks. Everything is then
configured via modifying files in `~/dotfiles`.

**Warning: the setup script is not idempotent.**

## Software

The `Brewfile` installs all the Homebrew formulae, Homebrew casks, and Mac App Store applications.

Update the Brewfile to reflect changes in your installation:

```bash
brew bundle dump --file tmp && mv tmp Brewfile
```

## Backup and restore

[Mackup](https://github.com/lra/mackup) is pre-configured to use an existing `Backup` folder in
Google Drive.

```bash
# Restore your files
mackup restore
```

## Structure

Repository organization:

- `setup` - setup script to install or update the dotfiles on your system
- `Brewfile` - a list of software to install via Homebrew into /opt/homebrew (ARM) or /usr/local
- `bin/*` - any executable scripts in this directory get added to your `$PATH`
- `config/*.zsh` - configuration files for ZSH; they are all sourced automatically into any new shell
- `functions/*` - zsh functions and autocomplete completion definitions
- `symlinks/*` - any files ending in `*.symlink` get linked by the `./setup` script into your home
  directory with the suffix removed (e.g. `gitignore.symlink` becomes `~/.gitignore`)

### Local files containing secrets

Use the `~/.localrc` file to export sensitive variables such as access tokens in Zsh. This file is
backed up and restored by Mackup.

## License

MIT License. See `LICENSE`.

## Inspiration

The following repositories served as inspiration for this repository:

- [jacobwgillespie/dotfiles](https://github.com/jacobwgillespie/dotfiles)
- [holman/dotfiles](https://github.com/holman/dotfiles)
- [ryanb/dotfiles](https://github.com/ryanb/dotfiles)
- [mathiasbynes/dotfiles](https://github.com/mathiasbynens/dotfiles)
