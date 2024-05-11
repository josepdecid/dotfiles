# Josep's .dotfiles ⚙️

This repository contains my personal dotfiles. I use them to configure my system and applications to my liking. Adding this to a public repo so I can easily clone it and setup a new machine with all my configs (and for reference and inspiration if you think it's useful somehow.)

## Managing Dotfiles

I use [GNU Stow](https://www.gnu.org/software/stow/) to manage my dotfiles. It's a symlink farm manager which takes distinct packages of software and/or data located in separate directories on the filesystem, and makes them appear to be installed in the same place.

Take as an example the file structure of any of my configured applications, *e.g.* Neovim. If we *stow* the `nvim` directory every file inside it will be symlinked to the corresponding location in the home directory, so all the stuff will be inside `~/.config/nvim`, the intended location for Neovim configuration files.

To stow an application configuration folder, just run the following command and you'll see the symlinks where they should be:

```bash
stow <application>
# Example: `stow nvim`
```

In that way you can stow/unstow any application configuration folder you want.