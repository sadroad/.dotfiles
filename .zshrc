[[ $- != *i* ]] && return

# Antidote plugin manager, installed through the AUR
source '/usr/share/zsh-antidote/antidote.zsh'
antidote load 
zstyle ':antidote:bundle' use-friendly-names 'yes'

#Force Emacs mode
bindkey -e
autoload -z edit-command-line
zle -N edit-command-line
bindkey "^X^E" edit-command-line

# Env variables
export DO_NOT_TRACK=1
export EDITOR="nvim"
export MANPAGER="sh -c 'col -bx | bat -l man -p'"
export WAYLAND_DISPLAY=wayland-1

#Aliases?
alias ls="eza"
alias cat="bat"
alias grep="rg"
alias tree="eza --tree"
alias top="btop"
alias du="dust"
alias vim="nvim"
alias xxd="0x"
alias l="ls -lah"
alias reload="source ~/.zshrc"
alias find="find"
alias open="xdg-open"
alias cd="z"

function cursor {
	(nohup /opt/cursor-bin/cursor-bin.AppImage $@ > /dev/null 2>&1 &)
}

alias drop-caches='sudo paccache -rk3; paru -Sc --aur --noconfirm'
alias update-all='export TMPFILE="$(mktemp)"; \
    sudo true; \
    rate-mirrors --save=$TMPFILE arch --max-delay=21600 \
      && sudo mv /etc/pacman.d/mirrorlist /etc/pacman.d/mirrorlist-backup \
      && sudo mv $TMPFILE /etc/pacman.d/mirrorlist \
      && drop-caches \
      && paru -Syyu --noconfirm'

export PATH="$HOME/.cargo/bin:$PATH"

source <(fnm env --use-on-cd --version-file-strategy=recursive)
source <(fzf --zsh)
source <(fnm completions --shell zsh)

eval "$(zoxide init zsh)"
