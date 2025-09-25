# versionzero - Fish Shell Configuration  
# ~/.config/fish/config.fish

# Disable fish greeting
set fish_greeting

# Set default editor
set -gx EDITOR nano
set -gx VISUAL nano

# Set browser
set -gx BROWSER firefox

# Add user bin to PATH if it exists
if test -d ~/bin
    set -gx PATH ~/bin $PATH
end

if test -d ~/.local/bin
    set -gx PATH ~/.local/bin $PATH
end

# Wayland environment variables
set -gx MOZ_ENABLE_WAYLAND 1
set -gx QT_QPA_PLATFORM wayland
set -gx QT_WAYLAND_DISABLE_WINDOWDECORATION 1
set -gx GDK_BACKEND wayland
set -gx XDG_CURRENT_DESKTOP Hyprland
set -gx XDG_SESSION_DESKTOP Hyprland
set -gx XDG_SESSION_TYPE wayland

# Fish colors (glassmorphism theme)
set fish_color_normal FFFFFF
set fish_color_command 928DAB --bold
set fish_color_keyword FF6B9D
set fish_color_quote 61E8A6
set fish_color_redirection 74B9FF --bold
set fish_color_end C44FFF
set fish_color_error FF6B9D --bold
set fish_color_param 54E6E6
set fish_color_comment 928DAB --italic
set fish_color_match 74B9FF --background=1F1C2C
set fish_color_selection FFFFFF --background=928DAB
set fish_color_search_match FFD93D --background=1F1C2C
set fish_color_history_current FFFFFF --bold
set fish_color_operator 61E8A6
set fish_color_escape 54E6E6 --bold
set fish_color_autosuggestion 928DAB
set fish_color_cancel FF6B9D
set fish_color_cwd 74B9FF --bold
set fish_color_cwd_root FF6B9D --bold
set fish_color_user 61E8A6 --bold
set fish_color_host 74B9FF
set fish_color_host_remote C44FFF
set fish_color_status FF6B9D

# Pager colors
set fish_pager_color_prefix 74B9FF --bold
set fish_pager_color_progress 928DAB --background=1F1C2C
set fish_pager_color_completion FFFFFF
set fish_pager_color_description 928DAB --italic
set fish_pager_color_selected_background --background=928DAB
set fish_pager_color_selected_prefix 1F1C2C --bold
set fish_pager_color_selected_completion 1F1C2C --bold
set fish_pager_color_selected_description 1F1C2C --bold

# History configuration  
set fish_history_max 10000

# Aliases
alias ll "ls -la --color=auto"
alias la "ls -A --color=auto" 
alias l "ls -CF --color=auto"
alias ls "ls --color=auto"
alias grep "grep --color=auto"
alias fgrep "fgrep --color=auto"
alias egrep "egrep --color=auto"

# Directory navigation
alias .. "cd .."
alias ... "cd ../.."
alias .... "cd ../../.."
alias ..... "cd ../../../.."

# Git aliases
alias g git
alias ga "git add"
alias gc "git commit"
alias gs "git status"
alias gp "git push"
alias gl "git log --oneline"
alias gd "git diff"
alias gb "git branch"
alias gco "git checkout"

# System aliases
alias c clear
alias h history
alias j jobs
alias df "df -h"
alias du "du -h"
alias free "free -h"
alias ps "ps aux"
alias psg "ps aux | grep"

# Package management
alias pacin "sudo pacman -S"
alias pacsearch "pacman -Ss"
alias pacrem "sudo pacman -Rns"
alias pacup "sudo pacman -Syu"
alias pacls "pacman -Q"
alias yayin "yay -S"
alias yayup "yay -Syu"

# Hyprland specific
alias hypconf "nano ~/.config/hypr/hyprland.conf"
alias wayconf "nano ~/.config/waybar/config.jsonc"
alias wayreload "killall waybar; waybar &"
alias hypreload "hyprctl reload"

# Quick configs
alias fishconf "nano ~/.config/fish/config.fish"
alias fishreload "source ~/.config/fish/config.fish"

# Network
alias ping "ping -c 3"
alias fastping "ping -c 100 -s 2"
alias ports "netstat -tuln"

# File operations
alias cp "cp -iv"
alias mv "mv -iv"
alias rm "rm -iv" 
alias mkdir "mkdir -pv"

# Archive operations
alias tar "tar -xzf"
alias untar "tar -xzf"

# System monitoring
alias cpu "grep 'cpu ' /proc/stat | awk '{usage=(\$2+\$4)*100/(\$2+\$3+\$4+\$5)} END {print usage}' | cut -d'.' -f1"
alias mem "free -m | awk 'NR==2{printf \"Memory Usage: %s/%sMB (%.2f%%)\n\", \$3,\$2,\$3*100/\$2 }'"
alias disk "df -h | awk '\$NF==\"/\"{printf \"Disk Usage: %d/%dGB (%s)\n\", \$3,\$2,\$5}'"

# Functions

# Create directory and cd into it
function mkcd
    mkdir -p $argv
    and cd $argv
end

# Extract any archive
function extract
    if test -f $argv[1]
        switch $argv[1]
            case '*.tar.bz2'
                tar xjf $argv[1]
            case '*.tar.gz'
                tar xzf $argv[1]
            case '*.bz2'
                bunzip2 $argv[1]
            case '*.rar'
                unrar x $argv[1]
            case '*.gz'
                gunzip $argv[1]
            case '*.tar'
                tar xf $argv[1]
            case '*.tbz2'
                tar xjf $argv[1]
            case '*.tgz'
                tar xzf $argv[1]
            case '*.zip'
                unzip $argv[1]
            case '*.Z'
                uncompress $argv[1]
            case '*.7z'
                7z x $argv[1]
            case '*'
                echo "'$argv[1]' cannot be extracted via extract()"
        end
    else
        echo "'$argv[1]' is not a valid file"
    end
end

# Get public IP
function myip
    curl -s http://ipecho.net/plain
    echo
end

# Weather function
function weather
    if test (count $argv) -eq 0
        set location "Jakarta"
    else
        set location $argv[1]
    end
    curl -s "wttr.in/$location?format=3"
end

# System info function
function sysinfo
    echo "System Information:"
    echo "=================="
    echo "Hostname: "(hostname)
    echo "Kernel: "(uname -r)
    echo "Architecture: "(uname -m)
    echo "Uptime: "(uptime -p)
    echo "Shell: "(echo $SHELL)
    echo "Desktop: $XDG_CURRENT_DESKTOP"
    echo "Memory Usage:"
    free -h | grep Mem | awk '{print "  Used: " $3 " / " $2 " (" $3/$2*100.0 "%)"}'
    echo "Disk Usage:"
    df -h / | tail -1 | awk '{print "  Used: " $3 " / " $2 " (" $5 ")"}'
end

# Git status in prompt function
function git_prompt
    if git rev-parse --git-dir > /dev/null 2>&1
        set -l branch (git branch --show-current 2>/dev/null)
        if test -n "$branch"
            set -l status (git status --porcelain 2>/dev/null)
            if test -n "$status"
                echo " ($branch*)"
            else
                echo " ($branch)"
            end
        end
    end
end

# Package count function
function pkgcount
    echo "Packages installed:"
    echo "==================="
    echo "Official packages: "(pacman -Q | wc -l)
    if command -v yay > /dev/null
        echo "AUR packages: "(yay -Qm | wc -l)
    end
end

# Clean system function
function cleanup
    echo "Cleaning system..."
    sudo pacman -Sc --noconfirm
    sudo pacman -Rns (pacman -Qtdq) 2>/dev/null
    if command -v yay > /dev/null
        yay -Sc --noconfirm
    end
    sudo journalctl --vacuum-time=3d
    echo "System cleaned!"
end

# Hyprland screenshot function
function screenshot
    if test (count $argv) -eq 0
        grim -g "(slurp)" - | wl-copy
        echo "Screenshot copied to clipboard"
    else
        switch $argv[1]
            case 'full'
                grim - | wl-copy
                echo "Full screenshot copied to clipboard"
            case 'save'
                set filename "screenshot-"(date +%Y%m%d-%H%M%S)".png"
                grim -g "(slurp)" ~/Pictures/$filename
                echo "Screenshot saved as $filename"
            case '*'
                echo "Usage: screenshot [full|save]"
        end
    end
end

# Update dotfiles function
function update-dots
    if test -d ~/.config/versionzero
        cd ~/.config/versionzero
        git pull origin main
        echo "Dotfiles updated!"
        cd -
    else
        echo "versionzero dotfiles not found"
    end
end

# Startup message
if status is-interactive
    # Run fastfetch if available
    if command -v fastfetch > /dev/null
        fastfetch
    else if command -v neofetch > /dev/null
        neofetch
    end
end

# Initialize starship prompt if available
if command -v starship > /dev/null
    starship init fish | source
end

# Initialize zoxide if available  
if command -v zoxide > /dev/null
    zoxide init fish | source
    alias cd z
end

# Initialize fzf if available
if command -v fzf > /dev/null
    # Set FZF colors to match theme
    set -gx FZF_DEFAULT_OPTS '--color=bg+:#1F1C2C,bg:#1F1C2C,spinner:#61E8A6,hl:#74B9FF --color=fg:#FFFFFF,header:#74B9FF,info:#C44FFF,pointer:#61E8A6 --color=marker:#61E8A6,fg+:#FFFFFF,prompt:#C44FFF,hl+:#74B9FF'
end