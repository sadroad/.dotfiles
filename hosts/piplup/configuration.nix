{
  config,
  pkgs,
  inputs,
  username,
  ...
}: {
  #just to remove brave bloat
  environment.etc."brave/policies/managed/policies.json" = {
    source = ./policies.json;
    mode = "0444";
    user = "root";
    group = "root";
  };

  programs.ssh.startAgent = true;
}
