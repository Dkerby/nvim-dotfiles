Dotfiles for neovim, tmux and the starship prompt

## Requirements

Neovim **0.12+** is required (the config uses the built-in `vim.pack` plugin manager).
Plugins install themselves on first launch; the packages below are the system-wide
tools the config expects.

### Arch

```sh
sudo pacman -S neovim tmux starship git base-devel curl unzip ripgrep fd wl-clipboard xclip \
  tree-sitter-cli nodejs npm prettier \
  rustup clang jdk-openjdk python dotnet-sdk
```

### Ubuntu (24.04+)

apt's `neovim` is too old, so install the official release instead:

```sh
curl -LO https://github.com/neovim/neovim/releases/latest/download/nvim-linux-x86_64.tar.gz
sudo tar -C /opt -xzf nvim-linux-x86_64.tar.gz
sudo ln -sf /opt/nvim-linux-x86_64/bin/nvim /usr/local/bin/nvim
```

Then the rest of the packages:

```sh
sudo apt install tmux git build-essential curl unzip ripgrep fd-find wl-clipboard xclip \
  nodejs npm \
  rustup clangd clang-format openjdk-21-jdk python3 dotnet-sdk-10.0
sudo npm install -g prettier
curl -sS https://starship.rs/install.sh | sh   # starship isn't in apt on 24.04
```

If apt can't find `dotnet-sdk-10.0`, add the .NET backports PPA first
(`sudo add-apt-repository ppa:dotnet/backports`).

### Both: Rust toolchain and tree-sitter CLI

```sh
rustup default stable
rustup component add rust-analyzer clippy rustfmt

# Arch only: the rustup package ships no rust-analyzer shim
ln -s /usr/bin/rustup ~/.local/bin/rust-analyzer

# Ubuntu only: apt's tree-sitter-cli is too old for nvim-treesitter (main branch).
# Make sure ~/.cargo/bin is on your PATH afterwards.
cargo install --locked tree-sitter-cli
```

### Both: Mason-managed language servers

Run inside Neovim, then restart it:

```vim
:MasonInstall jdtls csharp-language-server
```

Optional, for Solidity: `:MasonInstall nomicfoundation-solidity-language-server`.

### Font: Terminess Nerd Font

The configs assume a [Nerd Font](https://www.nerdfonts.com/) for icons; I use Terminess
(the Nerd Fonts build of Terminus).

```sh
# Arch
sudo pacman -S ttf-terminus-nerd

# Ubuntu (not packaged in apt, so install from the Nerd Fonts release)
mkdir -p ~/.local/share/fonts/Terminess
curl -fLo /tmp/Terminus.tar.xz https://github.com/ryanoasis/nerd-fonts/releases/latest/download/Terminus.tar.xz
tar -xJf /tmp/Terminus.tar.xz -C ~/.local/share/fonts/Terminess
fc-cache -f

# macOS
brew install --cask font-terminess-ttf-nerd-font
```

Check it's installed with `fc-list | grep -i terminess`, then point your terminal at it.
For [Ghostty](https://ghostty.org/), add this to `~/.config/ghostty/config`:

```
font-family = "Terminess Nerd Font"
font-size = 16
```

Use `ghostty +list-fonts | grep -i terminess` to see the exact family names available.

### What each piece is for

| Tool | Used for |
|------|----------|
| `ripgrep`, `fd` | Telescope live grep and file search |
| `wl-clipboard` / `xclip` | System clipboard (`clipboard=unnamedplus`); Wayland / X11 |
| `tree-sitter-cli`, C compiler | Compiling treesitter parsers |
| `unzip`, `curl` | Mason package downloads |
| `prettier` | JSON / JSONC formatting |
| `rust-analyzer`, `clippy`, `rustfmt` | Rust LSP, lints, formatting |
| `clangd`, `clang-format` | C / C++ LSP and formatting |
| JDK 21+, `python3`, `jdtls` | Java LSP (jdtls runs on the JDK; its launcher is a Python script) |
| .NET 10 SDK, `csharp-ls` | C# LSP |
| A [Nerd Font](https://www.nerdfonts.com/) (Terminess) | File icons in neo-tree, the tabline, completion and the starship prompt |

Java and C# have no separate formatter: they format through their language server.

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

# starship
ln -s "$PWD/starship/starship.toml" ~/.config/starship.toml
echo 'command -v starship >/dev/null && eval "$(starship init bash)"' >> ~/.bashrc
```

If you already have configs at those paths, back them up first:

```sh
mv ~/.config/nvim ~/.config/nvim.bak
mv ~/.config/tmux/tmux.conf ~/.config/tmux/tmux.conf.bak
mv ~/.tmux.conf ~/.tmux.conf.bak   # tmux prefers this over ~/.config/tmux/tmux.conf if it exists
```

### Verify

```sh
ls -l ~/.config/nvim ~/.config/tmux/tmux.conf ~/.config/starship.toml
```

All three should point back into this repo. Restart tmux (or press `prefix` + `R` inside it) to load the new config,
and run `source ~/.bashrc` (or open a new terminal) for the prompt.

## Keybindings

Only bindings that differ from Neovim and tmux defaults are listed.

### Neovim

Leader is <kbd>Space</kbd>. Neovim's built-in LSP keys also work: `K` hover, `grn` rename,
`gra` code action, `grr` references, `gri` implementation, `gO` symbols, `[d` / `]d` diagnostics.

| Keys | Mode | Action |
|------|------|--------|
| **General** | | |
| `<C-s>` | n | Save file |
| `<C-c>` | n | Copy whole file |
| `<Esc>` | n | Clear search highlight |
| `<leader>n` | n | Toggle line numbers |
| `<leader>rn` | n | Toggle relative numbers |
| `<leader>fm` | n, x | Format file / selection |
| `<leader>/` | n, v | Toggle comment |
| **Movement** | | |
| `<C-h>` `<C-j>` `<C-k>` `<C-l>` | n | Move between windows |
| `<C-h>` `<C-j>` `<C-k>` `<C-l>` | i | Move cursor left / down / up / right |
| `<C-b>` / `<C-e>` | i | Jump to start / end of line |
| **Buffers** | | |
| `<Tab>` / `<S-Tab>` | n | Next / previous buffer |
| `<leader>b` | n | New buffer |
| `<leader>x` | n | Close buffer |
| **Completion** (blink.cmp) | | |
| `<Tab>` | i | Accept suggestion |
| `<Up>` / `<Down>` | i | Previous / next suggestion |
| `<Esc>` | i | Hide suggestions |
| **LSP** | | |
| `gd` | n | Go to definition |
| `gD` | n | Go to declaration |
| `gy` | n | Go to type definition |
| `<leader>ih` | n | Toggle inlay hints |
| `<leader>ch` | n | Switch between source and header (C/C++) |
| `<leader>ds` | n | Diagnostics to location list |
| **Files** | | |
| `<C-n>` | n | Toggle file tree |
| `<leader>e` | n | Focus file tree |
| `<leader>ff` | n | Find files |
| `<leader>fa` | n | Find all files (hidden + ignored) |
| `<leader>fw` | n | Live grep |
| `<leader>fb` | n | Find buffers |
| `<leader>fo` | n | Recent files |
| `<leader>fz` | n | Fuzzy find in current buffer |
| `<leader>fh` | n | Help tags |
| `<leader>ma` | n | Marks |
| **Git** | | |
| `]c` / `[c` | n | Next / previous hunk |
| `<leader>hs` / `<leader>hr` | n, v | Stage / reset hunk (or selection) |
| `<leader>hS` / `<leader>hR` | n | Stage / reset buffer |
| `<leader>ph` | n | Preview hunk |
| `<leader>hd` | n | Diff this file |
| `<leader>gb` | n | Blame line |
| `<leader>cm` | n | Browse commits |
| `<leader>gt` | n | Git status |
| `ih` | o, x | Select hunk (text object) |
| **Terminal** | | |
| `<A-h>` / `<A-v>` / `<A-i>` | n, t | Toggle horizontal / vertical / floating terminal |
| `<leader>h` / `<leader>v` | n | Open a new horizontal / vertical terminal |
| `<C-x>` | t | Leave terminal mode |

### tmux

Prefix is <kbd>Ctrl</kbd>+<kbd>a</kbd>. All keys below follow the prefix.

| Keys | Action |
|------|--------|
| **Windows** | |
| `Ctrl-a` | Last window |
| `Ctrl-c` | New window (in `$HOME`) |
| `H` / `L` | Previous / next window |
| `r` | Rename window |
| `w` / `Ctrl-w` | List windows |
| `"` | Choose window |
| **Panes** | |
| `s` | Split top / bottom (current directory) |
| `v` | Split side by side (current directory) |
| `\|` | Split top / bottom |
| `h` `j` `k` `l` | Select pane left / down / up / right |
| `,` `.` | Resize pane left / right (repeatable) |
| `-` `=` | Resize pane down / up (repeatable) |
| `c` | Swap pane with the next one |
| `x` | Kill pane (no confirmation) |
| `*` | Toggle synchronized input across panes |
| `P` | Toggle pane border status |
| **Sessions** | |
| `S` | Choose session |
| `Ctrl-d` | Detach |
| `Ctrl-x` | Lock server |
| **Other** | |
| `R` | Reload config |
| `Ctrl-l` | Refresh client |
| `v` / `y` (copy mode) | Begin selection / copy and exit |
