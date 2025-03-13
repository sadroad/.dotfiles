if not status is-interactive
    return
end

switch (uname)
    case Darwin
        source ~/.config/fish/config_mac.fish
    case Linux
        source ~/.config/fish/config_linux.fish
end

#fish_add_path $HOME/.cargo/bin

set -x DO_NOT_TRACK 1
set -x PAGER delta
set -x EDITOR nvim
set -x VISUAL nvim
set -x MANPAGER "sh -c 'sed -u -e \"s/\\x1B\[[0-9;]*m//g; s/.\\x08//g\" | bat -p -lman'"

abbr --add ls eza
abbr --add l "eza -lah"
abbr --add cat bat
abbr --add grep rg
abbr --add tree "eza --tree"
abbr --add top btop
abbr --add du dust
abbr --add vim nvim
abbr --add vi nvim
abbr --add xxd 0x
abbr --add reload "source ~/.config/fish/config.fish"
abbr --add find fd
abbr --add cd z
abbr --add dig doggo
abbr --add ps procs
abbr --add ping gping
abbr --add diff delta
alias gzip pigz
abbr --add mkdir "mkdir -p"
abbr --add type "type -a"

function y
    set tmp (mktemp -t "yazi-cwd.XXXXXX")
    yazi $argv --cwd-file="$tmp"
    if set cwd (command cat -- "$tmp"); and [ -n "$cwd" ]; and [ "$cwd" != "$PWD" ]
        builtin cd -- "$cwd"
    end
    rm -f -- "$tmp"
end

fzf --fish | source

zoxide init fish | source

jj util completion fish | source

atuin init fish --disable-up-arrow | source
