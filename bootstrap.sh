#!/usr/bin/env bash
set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_DIR="${XDG_CONFIG_HOME:-$HOME/.config}"

install_file() {
	local src="$1"
	local dest="$2"

	mkdir -p "$(dirname "$dest")"

	if [[ -L "$dest" ]]; then
		rm -f "$dest"
	elif [[ -f "$dest" ]] && ! cmp -s "$src" "$dest"; then
		cp "$dest" "${dest}.bak"
	fi

	if [[ ! -f "$dest" ]] || ! cmp -s "$src" "$dest"; then
		cp "$src" "$dest"
	fi
}

install_file "$DOTFILES_DIR/zsh/.zshrc" "$HOME/.zshrc"
install_file "$DOTFILES_DIR/zsh/.zsh_plugins.txt" "$HOME/.zsh_plugins.txt"
install_file "$DOTFILES_DIR/ghostty/config" "$CONFIG_DIR/ghostty/config"
install_file "$DOTFILES_DIR/cmux/cmux.json" "$CONFIG_DIR/cmux/cmux.json"
install_file "$DOTFILES_DIR/zed/settings.json" "$CONFIG_DIR/zed/settings.json"
install_file "$DOTFILES_DIR/starship/starship.toml" "$CONFIG_DIR/starship.toml"
install_file "$DOTFILES_DIR/git/config" "$CONFIG_DIR/git/config"
install_file "$DOTFILES_DIR/git/ignore" "$CONFIG_DIR/git/ignore"
install_file "$DOTFILES_DIR/mise/config.toml" "$CONFIG_DIR/mise/config.toml"
install_file "$DOTFILES_DIR/ripgrep/config" "$CONFIG_DIR/ripgrep/config"
install_file "$DOTFILES_DIR/tealdeer/config.toml" "$CONFIG_DIR/tealdeer/config.toml"
install_file "$DOTFILES_DIR/gh/config.yml" "$CONFIG_DIR/gh/config.yml"

if command -v brew >/dev/null 2>&1; then
	HOMEBREW_NO_AUTO_UPDATE=1 brew bundle --file="$DOTFILES_DIR/Brewfile"
fi

if command -v mise >/dev/null 2>&1; then
	mise install
fi

if [[ ! -d "$CONFIG_DIR/nvim" ]]; then
	git clone https://github.com/nvim-lua/kickstart.nvim.git "$CONFIG_DIR/nvim"
elif [[ -d "$CONFIG_DIR/nvim/.git" ]]; then
	git -C "$CONFIG_DIR/nvim" pull --ff-only 2>/dev/null || true
fi

if command -v nvim >/dev/null 2>&1 && [[ -f "$CONFIG_DIR/nvim/init.lua" ]]; then
	nvim --headless "+qa" 2>/dev/null || true
fi
