{pkgs, ...}: {
  programs.helix = {
    enable = true;
    settings = {
      theme = "gruvbox";
    };
  };
}
