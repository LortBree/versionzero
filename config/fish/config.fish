# VersionZero Fish Shell Configuration

# Remove greeting
set fish_greeting

# Initialize Starship prompt
starship init fish | source

# Note: Fish cannot source bash export syntax
# Theme colors are handled differently in Fish
# They are set directly below for shell prompt colors

# Environment variables
set -gx EDITOR nvim
set -gx VISUAL nvim
set -gx BROWSER firefox
set -gx TERMINAL alacritty

# Add local bin to PATH
fish_add_path ~/.local/bin
fish_add_path ~/bin

# Aliases
alias ls='ls --color=auto'
alias ll='ls -lah --color=auto'
alias la='ls -A --color=auto'
alias l='ls -CF --color=auto'
alias grep='grep --color=auto'
alias fgrep='fgrep --color=auto'
alias egrep='egrep --color=auto'
alias df='df -h'
alias free='free -m'
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'

# VersionZero specific aliases
alias theme='~/.config/scripts/theme-switcher.sh'
alias wallpaper='~/.config/scripts/wallpaper-selector.sh'
alias nightlight='~/.config/scripts/night-light-toggle.sh'
alias performance='~/.config/scripts/performance-mode.sh'

# Git aliases
alias gs='git status'
alias ga='git add'
alias gc='git commit'
alias gp='git push'
alias gl='git log --oneline --graph'
alias gd='git diff'

# System management
alias update='sudo pacman -Syu'
alias install='sudo pacman -S'
alias remove='sudo pacman -Rns'
alias search='pacman -Ss'
alias cleanup='sudo pacman -Sc && yay -Sc'

# Quick navigation
alias config='cd ~/.config'
alias downloads='cd ~/Downloads'
alias documents='cd ~/Documents'
alias pictures='cd ~/Pictures'

# Functions
function mkcd
    mkdir -p $argv[1] && cd $argv[1]
end

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

# Color customization based on theme
# These will be updated when theme changes
set fish_color_normal FFFFFF
set fish_color_command 928DAB --bold
set fish_color_param FFFFFF
set fish_color_error F44336 --bold
set fish_color_quote 4CAF50
set fish_color_redirection FFC107
set fish_color_end 928DAB
set fish_color_comment 928DAB --dim
set fish_color_autosuggestion 928DAB
set fish_color_selection --background=928DAB

# Vi key bindings (optional, uncomment if preferred)
# fish_vi_key_bindings