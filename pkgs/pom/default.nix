{
  lib,
  rustPlatform,
  pkg-config,
  dbus,
}:

rustPlatform.buildRustPackage {
  pname = "pom";
  version = "0.1.0";

  src = ./.;

  cargoLock = {
    lockFile = ./Cargo.lock;
  };

  nativeBuildInputs = [ pkg-config ];

  buildInputs = [ dbus ];

  meta = {
    description = "Simple pomodoro timer CLI with desktop notifications";
    license = lib.licenses.mit;
    mainProgram = "pom";
  };
}
