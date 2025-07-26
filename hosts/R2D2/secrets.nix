{
  pkgs,
  inputs,
  username,
  secretsPath,
  secretsAvailable,
  lib,
  agenix,
  ...
}:
{
  imports = [agenix.nixosModules.default];
}
// (
  if secretsAvailable
  then {
    launchd.daemons."activate-agenix".serviceConfig = {
      StandardErrorPath = "/Library/Logs/org.nixos.activate-agenix.stderr.log";
      StandardOutPath = "/Library/Logs/org.nixos.activate-agenix.stdout.log";
    };

    environment.systemPackages = [inputs.agenix.packages."${pkgs.system}".default];

    age.identityPaths = ["/etc/ssh/ssh_host_ed25519_key"];

    age.secrets = {
      "sadroad-gpg-private" = {
        file = "${secretsPath}/sadroad-gpg-private.age";
        symlink = true;
        mode = "0400";
        owner = username;
      };
      "github_oauth" = {
        file = "${secretsPath}/github_oauth.age";
        symlink = true;
        mode = "0400";
        owner = username;
      };
    };
  }
  else {}
)
