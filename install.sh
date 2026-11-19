#!/usr/bin/env bash
set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ZSH_CUSTOM="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"

clone_if_missing() {
  local dest=$1 url=$2
  shift 2
  if [[ ! -d $dest ]]; then
    git clone "$@" "$url" "$dest"
  fi
}

install_oh_my_zsh_and_plugins() {
  if [[ ! -d $HOME/.oh-my-zsh ]]; then
    RUNZSH=no CHSH=no sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
  fi
  clone_if_missing "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting" \
    https://github.com/zsh-users/zsh-syntax-highlighting.git
  clone_if_missing "$ZSH_CUSTOM/plugins/zsh-autosuggestions" \
    https://github.com/zsh-users/zsh-autosuggestions
  clone_if_missing "$ZSH_CUSTOM/plugins/zsh-completions" \
    https://github.com/zsh-users/zsh-completions
  clone_if_missing "$ZSH_CUSTOM/themes/powerlevel10k" \
    https://github.com/romkatv/powerlevel10k.git --depth=1
}

install_darwin() {
  if ! command -v brew >/dev/null 2>&1; then
    echo "Installing Homebrew..."
    NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    # shellcheck disable=SC1091
    if [[ -f /opt/homebrew/bin/brew ]]; then
      eval "$(/opt/homebrew/bin/brew shellenv)"
    fi
  fi

  brew install cmake ripgrep git-lfs bat eza neovim fzf pre-commit
  brew install coreutils binutils diffutils findutils gawk gnu-indent gnu-sed gnu-tar gnu-which gnutls grep gzip watch wdiff wget gdb gpatch make git less openssh rsync unzip
  brew install --cask iterm2 font-jetbrains-mono-nerd-font

  clone_if_missing "$HOME/.config/iterm2-color-schemes" \
    https://github.com/mbadolato/iTerm2-Color-Schemes.git --depth=1
}

install_linux() {
  sudo apt-get update
  sudo DEBIAN_FRONTEND=noninteractive apt-get install -y \
    zsh git curl ripgrep cmake bat neovim fzf wget unzip python3-pip
  if apt-cache show pre-commit >/dev/null 2>&1; then
    sudo DEBIAN_FRONTEND=noninteractive apt-get install -y pre-commit
  else
    pip3 install --user pre-commit
  fi

  if apt-cache show eza >/dev/null 2>&1; then
    sudo DEBIAN_FRONTEND=noninteractive apt-get install -y eza
  elif ! command -v eza >/dev/null 2>&1; then
    arch="$(uname -m)"
    case "$arch" in
      x86_64) eza_arch=x86_64-unknown-linux-gnu ;;
      aarch64) eza_arch=aarch64-unknown-linux-gnu ;;
      *) echo "eza: no release for $arch; install manually" >&2; eza_arch= ;;
    esac
    if [[ -n ${eza_arch:-} ]]; then
      eza_url="https://github.com/eza-community/eza/releases/latest/download/eza_${eza_arch}.tar.gz"
      tmp="$(mktemp -d)"
      curl -fsSL "$eza_url" | tar -xzf - -C "$tmp"
      install -m 755 "$tmp/eza" "$HOME/.local/bin/eza" 2>/dev/null || {
        mkdir -p "$HOME/.local/bin"
        install -m 755 "$tmp/eza" "$HOME/.local/bin/eza"
      }
      rm -rf "$tmp"
    fi
  fi

  if command -v batcat >/dev/null 2>&1 && ! command -v bat >/dev/null 2>&1; then
    mkdir -p "$HOME/.local/bin"
    ln -sf "$(command -v batcat)" "$HOME/.local/bin/bat"
  fi

  if command -v zsh >/dev/null 2>&1 && [[ "$(getent passwd "$USER" | cut -d: -f7)" != "$(command -v zsh)" ]]; then
    echo "To use zsh as your login shell, run: chsh -s $(command -v zsh)"
  fi
}

echo "Installing dotfiles tooling from $DOTFILES_DIR"

case "$(uname -s)" in
  Darwin) install_darwin ;;
  Linux) install_linux ;;
  *)
    echo "Unsupported OS: $(uname -s). Only Darwin and Linux are supported." >&2
    exit 1
    ;;
esac

install_oh_my_zsh_and_plugins

echo "Done. Run ./bootstrap.sh to symlink dotfiles into your home directory."
