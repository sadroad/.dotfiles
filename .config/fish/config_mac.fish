fish_add_path /opt/homebrew/bin
fish_add_path /opt/homebrew/sbin
fish_add_path "/Applications/Racket v8.15/bin"
fish_add_path /Users/sadroad/Library/pnpm

set -x GPG_TTY $(tty)
set -x XDG_RUNTIME_DIR /tmp/

if test -f "/Users/sadroad/.ghcup/env"
    replay "source '/Users/sadroad/.ghcup/env'"
end

alias tailscale "/Applications/Tailscale.app/Contents/MacOS/Tailscale"
alias bubu "brew update && brew upgrade && brew cleanup"
alias jj "jj --config-file=$HOME/.config/jj/config.base.toml --config-file=$HOME/.config/jj/config.mac.toml"

function update
    echo "updating rust"
    rustup update stable
    cargo install-update -a --locked

    echo "updating homebrew"
    bubu

    echo "updating fish"
    fisher update
    fish_update_completions

    echo "Do you want to update macOS? (y/N)"
    read -l confirm
    if test "$confirm" = y -o "$confirm" = Y
        echo "updating apple"
        /usr/sbin/softwareupdate -ia
    else
        echo "Skipping macOS update"
    end
end

alias dns-down 'sudo -v && tailscale down && sudo networksetup -setdnsservers "Wi-Fi" empty && sudo killall -HUP mDNSResponder'
alias dns-up 'sudo -v && tailscale up && sudo networksetup -setdnsservers "Wi-Fi" 1.1.1.2 1.1.1.1 1.0.0.1 9.9.9.9 && sudo killall -HUP mDNSResponder'
abbr --add dns-reset "dns-down && dns-up"

function cursor
    /Application/Cursor.app/Contents/Resources/app/bin/cursor $argv &
    disown
end
