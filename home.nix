{
  config,
  lib,
  pkgs,
  username,
  inputs,
  osConfig,
  ...
}: let
  vesktop =
    pkgs.vesktop.overrideAttrs
    (oldAttrs: {
      postPatch = ''
        mkdir -p static #ensuring that the folder exists
        rm -f static/shiggy.gif
        cp ${./shiggy.gif} static/shiggy.gif
      '';
    });
in rec {
  home.packages = with pkgs; [
    git-secrets
    caido
    ungoogled-chromium
    libreoffice-qt6-fresh

    hydra-check

    yaak
  ];

  programs.ghostty = {
    enable = true;
    settings = {
      shell-integration-features = "sudo";
      command = "fish --login --interactive";
      theme = "GruvboxDark";
      font-family = "Berkeley Mono Variable";
      font-style = "Retina";
      font-size = "14";
    };
  };

  programs.ssh = {
    enable = true;
    extraConfig = ''
      Host tux
      	HostName tux.cs.drexel.edu
      	User av676
    '';
  };

  home.shell.enableFishIntegration = true;

  dconf.settings = {
    "org/virt-manager/virt-manager/connections" = {
      autoconnect = ["qemu:///system"];
      uris = ["qemu:///system"];
    };
  };
}
