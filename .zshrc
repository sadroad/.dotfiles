[[ $- != *i* ]] && return

case "$(uname)" in
  Darwin)
    source ~/.zshrc_mac
    ;;
  Linux)
    source ~/.zshrc_linux
    ;;
esac

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
export MANROFFOPT="-c"
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
alias cd="z"
alias dig="doggo"
alias ps="procs"
alias ping="gping"
alias parallel="rust-parallel"
alias diff=delta

function y() {
	local tmp="$(mktemp -t "yazi-cwd.XXXXXX")" cwd
	yazi "$@" --cwd-file="$tmp"
	if cwd="$(command cat -- "$tmp")" && [ -n "$cwd" ] && [ "$cwd" != "$PWD" ]; then
		builtin cd -- "$cwd"
	fi
	rm -f -- "$tmp"
}

export PATH="$HOME/.cargo/bin:$PATH"

source <(fnm env --use-on-cd --version-file-strategy=recursive)
source <(fnm completions --shell zsh)

source <(fzf --zsh)

eval "$(zoxide init zsh)"

source <(jj util completion zsh)

eval "$(atuin init zsh --disable-up-arrow)"

