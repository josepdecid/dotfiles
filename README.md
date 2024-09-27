# Josep's .dotfiles ⚙️

This repository contains my personal dotfiles. I use them to configure my system and applications to my liking. Adding this to a public repo so I can easily clone it and setup a new machine with all my configs (and for reference and inspiration if you think it's useful somehow.)

## Managing Dotfiles

I use [GNU Stow](https://www.gnu.org/software/stow/) to manage my dotfiles. It's a symlink farm manager which takes distinct packages of software and/or data located in separate directories on the filesystem, and makes them appear to be installed in the same place.

Although directory naming can look a bit weird, it's a very simple and effective way to manage dotfiles. It allows me to have separated configurations for each application under the same folder even if the files target directory are different within the same application. E.g. check `zsh` which will move the `.zshenv` to `$HOME` and `.zshrc` to `$HOME/.config/zsh/`.

To stow an application configuration folder, just run the following command and you'll see the symlinks where they should be:

```bash
# Example: `stow nvim`
stow <application>

# To unstow it, just run:
stow -D <application>
```

You can also run `./install.sh` which stows all the preconfigured directories.

If running into any problems with already existing configuration files try the following commands:

```bash
# Remove the previously existing configuration
rm -rf ~/.config/<application>

# Backup the previously existing configuration
mv ~/.config/<application> ~/.config/<application>.backup
```
