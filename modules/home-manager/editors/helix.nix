{pkgs, ...}: {
  programs.helix = {
    defaultEditor = true;
    enable = true;
    settings = {
      theme = "gruvbox";
    };
    languages = {
      language-server.typescript-language-server = with pkgs.nodePackages; {
        command = "${typescript-language-server}/bin/typescript-language-server";
        args = ["--stdio"];
      };
    };
  };
}
