# Dotfiles

Dotfiles for configuring M1 Mac with ZSH and Homebrew.

## Requirements

- M1 MacOS

## Installation

```bash
$ git clone https://github.com/robb-romans/dotfiles.git ~/dotfiles
$ cd ~/dotfiles
$ ./setup
```

This will install all required dotfiles in your home directory as symlinks. Everything is then
configured via modifying files in `~/dotfiles`.

**Warning: the setup script is not yet idempotent.**

## Software

The `Brewfile` installs all the Homebrew formulae, Homebrew casks, and Mac App Store applications.

## Structure

Repository organization:

- `setup` - setup script that can be used to install or update the dotfiles on your system
- `Brewfile` - a list of software to install via Homebrew into /opt/homebrew
- `bin/*` - any executable scripts in this directory are added to your `$PATH`
- `config/*.zsh` - configuration files for ZSH; they are all sourced automatically into any new shell
- `functions/*` - zsh functions and autocomplete completion definitions
- `symlinks/*` - any files ending in `*.symlink` get linked by the `./setup` script into your home
  directory with the suffix removed (e.g. `gitignore.symlink` becomes `~/.gitignore`)

## License

MIT License. See `LICENSE`.

## Inspiration

The following repositories served as inspiration for this repository:

- [jacobwgillespie/dotfiles](https://github.com/jacobwgillespie/dotfiles)
- [holman/dotfiles](https://github.com/holman/dotfiles)
- [ryanb/dotfiles](https://github.com/ryanb/dotfiles)
- [mathiasbynes/dotfiles](https://github.com/mathiasbynens/dotfiles)
