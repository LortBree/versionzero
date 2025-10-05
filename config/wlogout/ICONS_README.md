# VersionZero Wlogout Icons Reference

## Icon Locations

Wlogout looks for icons in these locations (in order):
1. `/usr/share/wlogout/icons/`
2. `/usr/local/share/wlogout/icons/`
3. `~/.local/share/wlogout/icons/`

## Required Icons

The following icons are needed for the four-leaf clover layout:

| Icon File | Action | Material Design Icon Code |
|-----------|--------|---------------------------|
| `lock.png` | Lock screen | `` (lock) |
| `logout.png` | Logout/Exit | `` (exit_to_app) |
| `suspend.png` | Sleep/Suspend | `` (bedtime) |
| `shutdown.png` | Power off | `` (power_settings_new) |
| `reboot.png` | Restart | `` (restart_alt) |

## Creating Custom Icons

If default wlogout icons don't exist, you can create custom ones:

### Method 1: Use Material Design Icons (Recommended)

```bash
# Install icon pack
yay -S papirus-icon-theme

# Create custom icon directory
mkdir -p ~/.local/share/wlogout/icons

# Symlink from system icons
cd ~/.local/share/wlogout/icons
ln -s /usr/share/icons/Papirus/64x64/apps/system-lock-screen.svg lock.png
ln -s /usr/share/icons/Papirus/64x64/apps/system-log-out.svg logout.png
ln -s /usr/share/icons/Papirus/64x64/apps/system-suspend.svg suspend.png
ln -s /usr/share/icons/Papirus/64x64/apps/system-shutdown.svg shutdown.png
ln -s /usr/share/icons/Papirus/64x64/apps/system-reboot.svg reboot.png
```

### Method 2: Generate with ImageMagick

```bash
mkdir -p ~/.local/share/wlogout/icons
cd ~/.local/share/wlogout/icons

# Create simple colored icons (128x128px)
convert -size 128x128 xc:transparent -font "Material-Design-Icons" \
    -pointsize 80 -fill white -gravity center -annotate +0+0 "" lock.png

convert -size 128x128 xc:transparent -font "Material-Design-Icons" \
    -pointsize 80 -fill white -gravity center -annotate +0+0 "" logout.png

convert -size 128x128 xc:transparent -font "Material-Design-Icons" \
    -pointsize 80 -fill white -gravity center -annotate +0+0 "" suspend.png

convert -size 128x128 xc:transparent -font "Material-Design-Icons" \
    -pointsize 80 -fill white -gravity center -annotate +0+0 "" shutdown.png

convert -size 128x128 xc:transparent -font "Material-Design-Icons" \
    -pointsize 80 -fill white -gravity center -annotate +0+0 "" reboot.png
```

### Method 3: Download Pre-made Icons

```bash
# Clone wlogout default icons
git clone https://github.com/ArtsyMacaw/wlogout.git /tmp/wlogout
mkdir -p ~/.local/share/wlogout/icons
cp /tmp/wlogout/icons/* ~/.local/share/wlogout/icons/
```

## Troubleshooting

If icons don't appear:

1. Check icon paths in CSS are correct
2. Verify icon files exist: `ls ~/.local/share/wlogout/icons/`
3. Check permissions: `chmod 644 ~/.local/share/wlogout/icons/*`
4. Test with absolute paths in `style.css`

## Custom Icon Styling

Icons can be customized in `style.css`:
- Change `background-size` to adjust icon size
- Modify `background-position` for icon placement
- Add filters for color effects (e.g., `filter: brightness(1.2);`)