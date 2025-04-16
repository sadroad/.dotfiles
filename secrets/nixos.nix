{
  config,
  pkgs,
  inputs,
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
    "1.jpg" = {
      file = "${my_secrets}/1.jpg.age";
      symlink = true;
      mode = "0400";
      owner = username;
    };
    "change.jpg" = {
      file = "${my_secrets}/change.jpg.age";
      symlink = true;
      mode = "0400";
      owner = username;
    };
  };
}
