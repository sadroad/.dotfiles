{
  pkgs,
  lib,
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

  users.knownUsers = ["sadroad"];
  users.users.sadroad.uid = 501;

  system.defaults = {
    dock.autohide = true;
  };

  nix.enable = false;

  programs.fish.enable = true;
}
