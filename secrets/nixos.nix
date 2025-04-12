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
    "placeholder.txt" = {
      symlink = true;
      file = "${my_secrets}/placeholder.txt.age";
      mode = "0400";
      owner = username;
    };
    "sadroad-gpg-private" = {
      file = "${my_secrets}/sadroad-gpg-private.age";
      symlink = true;
      mode = "0400";
      owner = username;
    };
  };
}
