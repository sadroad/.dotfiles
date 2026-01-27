{
  lib,
  rust-bin,
  makeRustPlatform,
}:
let
  rustToolchain = rust-bin.stable.latest.default;
  rustPlatform = makeRustPlatform {
    cargo = rustToolchain;
    rustc = rustToolchain;
  };
in
rustPlatform.buildRustPackage {
  pname = "pom";
  version = "0.1.0";

  src = ./.;

  cargoLock = {
    lockFile = ./Cargo.lock;
  };

  meta = {
    description = "Simple pomodoro timer CLI with desktop notifications";
    license = lib.licenses.unlicense;
    mainProgram = "pom";
  };
}
