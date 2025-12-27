{pkgs, ...}: {
  programs.helix = {
    defaultEditor = true;
    enable = true;
    settings = {
      theme = "gruvbox";
    };
  };
}
