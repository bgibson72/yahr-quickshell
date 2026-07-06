# ~/.zshrc

# Enable colors and change prompt:
autoload -U colors && colors
PS1="%B%{$fg[cyan]%}[%{$fg[yellow]%}%n%{$fg[green]%}@%{$fg[blue]%}%M %{$fg[magenta]%}%~%{$fg[cyan]%}]%{$reset_color%}$%b "

# History settings
HISTSIZE=10000
SAVEHIST=10000
HISTFILE=~/.zsh_history

# Basic auto/tab complete:
autoload -U compinit
zstyle ':completion:*' menu select
zmodload zsh/complist
compinit
_comp_options+=(globdots)  # Include hidden files

# Aliases
alias ls='ls --color=auto'
alias grep='grep --color=auto'
alias ll='ls -lah'
alias la='ls -A'
alias l='ls -CF'

# Kitty integration (if running in kitty)
if test -n "$KITTY_INSTALLATION_DIR"; then
    export KITTY_SHELL_INTEGRATION="enabled"
    autoload -Uz -- "$KITTY_INSTALLATION_DIR"/shell-integration/zsh/kitty-integration
    kitty-integration
    unfunction kitty-integration
fi

# Run fastfetch on new terminal (but not in tmux/screen)
if [[ -z "$TMUX" && -z "$STY" ]]; then
    if command -v fastfetch >/dev/null 2>&1; then
        if [[ -f ~/.config/fastfetch/run-fastfetch-kitty.sh ]]; then
            bash ~/.config/fastfetch/run-fastfetch-kitty.sh
        elif [[ -f ~/.config/fastfetch/config.jsonc ]]; then
            fastfetch --config ~/.config/fastfetch/config.jsonc
        else
            fastfetch
        fi
    fi
fi
