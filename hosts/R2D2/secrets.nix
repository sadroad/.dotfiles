{
  pkgs,
  inputs,
  username,
  ...
}: {
  imports = [
    inputs.agenix.nixosModules.default
  ];

  environment.systemPackages = [
    inputs.agenix.packages."${pkgs.system}".default
  ];

  age.identityPaths = [
    "/Users/${username}/.ssh/id_ed25519"
  ];

  age.secrets = {
    "sadroad-gpg-private" = {
      file = "${inputs.my_secrets}/sadroad-gpg-private.age";
      mode = "0400";
      owner = username;
      symlink = true;
    };
    "github_oauth" = {
      file = "${inputs.my_secrets}/github_oauth.age";
      symlink = true;
      mode = "0400";
      owner = username;
    };
  };
}
