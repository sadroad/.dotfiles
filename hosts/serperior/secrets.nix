{
  pkgs,
  username,
  agenix,
  secretsPath,
  secretsAvailable,
  lib,
  ...
}:
lib.mkIf secretsAvailable {
  imports = [agenix.nixosModules.default];

  environment.systemPackages = [agenix.packages."${pkgs.system}".default];

  age.identityPaths = ["/etc/ssh/ssh_host_ed25519_key"];

  age.secrets = {
    "sadroad-gpg-private" = {
      file = "${secretsPath}/sadroad-gpg-private.age";
      symlink = true;
      mode = "0400";
      owner = username;
    };
    "berkeley_mono.zip" = {
      file = "${secretsPath}/berkeley_mono.zip.age";
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
