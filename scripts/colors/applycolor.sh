#!/usr/bin/env bash

QUICKSHELL_CONFIG_NAME="ii"
XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
XDG_CACHE_HOME="${XDG_CACHE_HOME:-$HOME/.cache}"
XDG_STATE_HOME="${XDG_STATE_HOME:-$HOME/.local/state}"
CONFIG_DIR="$XDG_CONFIG_HOME/quickshell/$QUICKSHELL_CONFIG_NAME"
CACHE_DIR="$XDG_CACHE_HOME/quickshell"
STATE_DIR="$XDG_STATE_HOME/quickshell"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

term_alpha=100 #Set this to < 100 make all your terminals transparent
# sleep 0 # idk i wanted some delay or colors dont get applied properly
if [ ! -d "$STATE_DIR"/user/generated ]; then
  mkdir -p "$STATE_DIR"/user/generated
fi
cd "$CONFIG_DIR" || exit

colornames=''
colorstrings=''
colorlist=()
colorvalues=()

mapfile -t colorlist < <(cut -d: -f1 "$STATE_DIR/user/generated/material_colors.scss")
mapfile -t colorvalues < <(cut -d: -f2 "$STATE_DIR/user/generated/material_colors.scss" | cut -d ' ' -f2 | cut -d ";" -f1)

apply_kitty() {  
  # Check if terminal escape sequence template exists
  if [ ! -f "$SCRIPT_DIR/terminal/kitty-theme.conf" ]; then
    echo "Template file not found for Kitty theme. Skipping that."
    return
  fi
  if [ ${#colorlist[@]} -eq 0 ]; then
    echo "No colors found in material_colors.scss. Skipping Kitty theme update."
    return
  fi

  # Generate to temporary file first so kitty never reads an incomplete template
  mkdir -p "$STATE_DIR"/user/generated/terminal
  local tmp_file
  tmp_file="$(mktemp "$STATE_DIR/user/generated/terminal/kitty-theme.XXXXXX.tmp")"
  cp "$SCRIPT_DIR/terminal/kitty-theme.conf" "$tmp_file"

  # Apply colors
  for i in "${!colorlist[@]}"; do
    col="${colorlist[$i]//\$/\\\$}"
    sed -i "s/${col} #/${colorvalues[$i]#\#}/g" "$tmp_file"
  done

  # Atomically replace live config only if variables were resolved
  if ! grep -q '#\$' "$tmp_file"; then
    mv "$tmp_file" "$STATE_DIR"/user/generated/terminal/kitty-theme.conf
  else
    echo "Warning: Unresolved variables in kitty theme. Keeping existing theme." >&2
    rm -f "$tmp_file"
  fi

  # Reload
  kill -SIGUSR1 $(pidof kitty) 2>/dev/null || true
}

apply_anyterm() {
  # Check if terminal escape sequence template exists
  if [ ! -f "$SCRIPT_DIR/terminal/sequences.txt" ]; then
    echo "Template file not found for Terminal. Skipping that."
    return
  fi
  if [ ${#colorlist[@]} -eq 0 ]; then
    echo "No colors found in material_colors.scss. Skipping terminal sequences update."
    return
  fi

  # Generate to temporary file first
  mkdir -p "$STATE_DIR"/user/generated/terminal
  local tmp_file
  tmp_file="$(mktemp "$STATE_DIR/user/generated/terminal/sequences.XXXXXX.tmp")"
  cp "$SCRIPT_DIR/terminal/sequences.txt" "$tmp_file"

  # Apply colors
  for i in "${!colorlist[@]}"; do
    col="${colorlist[$i]//\$/\\\$}"
    sed -i "s/${col} #/${colorvalues[$i]#\#}/g" "$tmp_file"
  done

  sed -i "s/\$alpha/$term_alpha/g" "$tmp_file"

  mv "$tmp_file" "$STATE_DIR"/user/generated/terminal/sequences.txt

  for file in /dev/pts/*; do
    if [[ $file =~ ^/dev/pts/[0-9]+$ ]]; then
      {
      cat "$STATE_DIR"/user/generated/terminal/sequences.txt >"$file"
      } & disown || true
    fi
  done
}

apply_term() {
  apply_kitty
  apply_anyterm
}

apply_qt() {
  sh "$CONFIG_DIR/scripts/kvantum/materialQT.sh"          # generate kvantum theme
  python "$CONFIG_DIR/scripts/kvantum/changeAdwColors.py" # apply config colors
}

# Check if terminal theming is enabled in config
CONFIG_FILE="$XDG_CONFIG_HOME/illogical-impulse/config.json"
if [ -f "$CONFIG_FILE" ]; then
  enable_terminal=$(jq -r '.appearance.wallpaperTheming.enableTerminal' "$CONFIG_FILE")
  if [ "$enable_terminal" = "true" ]; then
    apply_term
  fi
else
  echo "Config file not found at $CONFIG_FILE. Applying terminal theming by default."
  apply_term
fi

# apply_qt & # Qt theming is already handled by kde-material-colors
