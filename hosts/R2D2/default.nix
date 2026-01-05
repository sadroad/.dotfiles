{
  inputs,
  hostname,
  ...
}:
{
  imports = [
    ./configuration.nix
    ./secrets.nix

    ../../modules/darwin/core.nix

    inputs.mac-app-util.darwinModules.default
  ];

  networking.hostName = hostname;

  system.stateVersion = 6;
}
