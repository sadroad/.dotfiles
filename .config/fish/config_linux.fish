set -x WAYLAND_DISPLAY wayland-1
fish_add_path $HOME/.ghcup/bin

abbr --add open xdg-open
alias jj "jj --config-file=$HOME/.config/jj/config.base.toml --config-file=$HOME/.config/jj/config.linux.toml"

function cursor
    /opt/cursor-bin/cursor-bin.AppImage $argv &
    disown
end

function drop-caches
    sudo paccache -rk3
    paru -Sc --aur --noconfirm
end

function update-all
    set TMPFILE (mktemp)
    sudo -v
    rate-mirrors --save=$TMPFILE arch --max-delay=21600
    and sudo mv /etc/pacman.d/mirrorlist /etc/pacman.d/mirrorlist-backup
    and sudo mv $TMPFILE /etc/pacman.d/mirrorlist
    and drop-caches
    and paru -Syyu --noconfirm
end

function update
    sudo -v

    and echo "updating rust"
    and rustup update stable
    and cargo install-update -a --locked

    and echo "updating arch"
    and paru

    and echo "updating fish"
    and fisher update
    and fish_update_completions
end
