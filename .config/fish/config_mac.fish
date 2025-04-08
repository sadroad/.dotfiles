set -x GPG_TTY $(tty)
set -x XDG_RUNTIME_DIR /tmp/

alias tailscale "/Applications/Tailscale.app/Contents/MacOS/Tailscale"
alias jj "jj --config-file=$HOME/.config/jj/config.base.toml --config-file=$HOME/.config/jj/config.mac.toml"

function rebuild
    darwin-rebuild switch --flake "$(readlink -f ~/.config/nix)#R2D2"
end

function update
    echo "updating nix"
    rebuild

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
