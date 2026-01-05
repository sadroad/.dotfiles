{
  pkgs,
  username,
  agenix,
  secretsPath,
  secretsAvailable,
  lib,
  ...
}:
{
  imports = [ agenix.nixosModules.default ];
}
// lib.mkIf secretsAvailable {
  environment.systemPackages = [ agenix.packages."${pkgs.stdenv.hostPlatform.system}".default ];

  age.identityPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];

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
    "wg-conf" = {
      file = "${secretsPath}/piplup.conf.age";
      symlink = true;
      mode = "0400";
      owner = username;
    };
  };
}
