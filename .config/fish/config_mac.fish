fish_add_path /opt/homebrew/bin
fish_add_path /opt/homebrew/sbin
fish_add_path "/Applications/Racket v8.15/bin"
fish_add_path /Users/sadroad/Library/pnpm

set -x GPG_TTY $(tty)
set -x XDG_RUNTIME_DIR /tmp/

if test -f "/Users/sadroad/.ghcup/env"
    source "/Users/sadroad/.ghcup/env"
end

alias tailscale "/Applications/Tailscale.app/Contents/MacOS/Tailscale"
abbr --add bubu "brew update && brew upgrade && brew cleanup"
alias jj "jj --config-file=$HOME/.config/jj/config.base.toml --config-file=$HOME/.config/jj/config.mac.toml"

function update
    rustup update stable
    cargo install-update -a --locked
    bubu
    fisher
    fish_update_completions
    /usr/sbin/softwareupdate -ia
end

abbr --add dns-down 'sudo -v && tailscale down && sudo networksetup -setdnsservers "Wi-Fi" empty && sudo killall -HUP mDNSResponder'
abbr --add dns-up 'sudo -v && tailscale up && sudo networksetup -setdnsservers "Wi-Fi" 1.1.1.2 1.1.1.1 1.0.0.1 9.9.9.9 && sudo killall -HUP mDNSResponder'

function cursor
    /Application/Cursor.app/Contents/Resources/app/bin/cursor $argv &
    disown
end
