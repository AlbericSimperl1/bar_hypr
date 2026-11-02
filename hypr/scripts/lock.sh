#!/usr/bin/env bash
# Lock with hyprlock, themed from awww's current wallpaper and noctalia's palette.

pidof hyprlock >/dev/null && exit 0

CACHE="$HOME/.cache/hyprlock"
mkdir -p "$CACHE"

wall=$(awww query 2>/dev/null | sed -n 's/.*currently displaying: image: //p' | head -n1)
[ -f "$wall" ] || wall=$(find "$HOME/Pictures/wallpapers" -type f \( -name '*.jpg' -o -name '*.png' -o -name '*.webp' \) | head -n1)

# noctalia regenerates the kitty theme on every wallpaper change, so its palette is the system palette
theme="$HOME/.config/kitty/themes/noctalia.conf"
primary=$(awk '/^active_border_color/{sub("#","",$2); print $2}' "$theme" 2>/dev/null)
fg=$(awk '/^foreground/{sub("#","",$2); print $2}' "$theme" 2>/dev/null)
err=$(awk '/^color1 /{sub("#","",$2); print $2}' "$theme" 2>/dev/null)

cat > "$CACHE/vars.conf" <<EOF
\$wallpaper = $wall
\$primary = rgb(${primary:-98cbff})
\$fg = rgb(${fg:-e0e2e8})
\$error = rgb(${err:-ffb4ab})
EOF

exec hyprlock
