{
  pkgs,
  lib,
  username,
  ...
}: {
  environment.systemPackages = with pkgs; [
    neovim
    fish
    atuin
    bats
    btop
    bun
    cloudflared
    qbittorrent
    curl
    pv
    doggo
    fastfetch
    fzf
    git
    delta
    ijq
    infisical
    jujutsu
    file
    miniserve
    yazi
    stow
    bat
    zoxide
    tealdeer
    eza
    dust
    fd
    ripgrep
    procs
    mdbook
    hyperfine
    gping
    _0x
    pigz
    nodejs_22
    rustscan
    vscode
    vesktop
    viu
  ];
  users = {
    knownUsers = [username];
    users.${username}.uid = 501;
    users.${username}.shell = pkgs.fish;
  };
}
