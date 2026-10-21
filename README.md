Dotfiles for neovim and tmux

## Installation (macOS / Linux)

Clone the repo, then symlink the configs into `~/.config`:

```sh
git clone https://github.com/Dkerby/nvim-dotfiles.git ~/dev/nvim-dotfiles
cd ~/dev/nvim-dotfiles

mkdir -p ~/.config/tmux

# Neovim
ln -s "$PWD/nvim" ~/.config/nvim

# tmux (3.1+ reads ~/.config/tmux/tmux.conf)
ln -s "$PWD/tmux/.tmux.conf" ~/.config/tmux/tmux.conf
```

If you already have configs at those paths, back them up first:

```sh
mv ~/.config/nvim ~/.config/nvim.bak
mv ~/.config/tmux/tmux.conf ~/.config/tmux/tmux.conf.bak
mv ~/.tmux.conf ~/.tmux.conf.bak   # tmux prefers this over ~/.config/tmux/tmux.conf if it exists
```

### Verify

```sh
ls -l ~/.config/nvim ~/.config/tmux/tmux.conf
```

Both should point back into this repo. Restart tmux (or press `prefix` + `R` inside it) to load the new config.
