{
  pkgs,
  username,
  agenix,
  my_secrets,
  ...
}: {
  imports = [
    agenix.nixosModules.default
  ];

  environment.systemPackages = [
    agenix.packages."${pkgs.system}".default
  ];

  age.identityPaths = [
    "/etc/ssh/ssh_host_ed25519_key"
  ];

  age.secrets = {
    "sadroad-gpg-private" = {
      file = "${my_secrets}/sadroad-gpg-private.age";
      symlink = true;
      mode = "0400";
      owner = username;
    };
    "berkeley_mono.zip" = {
      file = "${my_secrets}/berkeley_mono.zip.age";
      symlink = true;
      mode = "0400";
      owner = username;
    };
    "github_oauth" = {
      file = "${my_secrets}/github_oauth.age";
      symlink = true;
      mode = "0400";
      owner = username;
    };
    "wg-conf" = {
      file = "${my_secrets}/piplup.conf.age";
      symlink = true;
      mode = "0400";
      owner = username;
    };
  };
}
