{
  description = "Developer environment for installing and running tvc";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs = { nixpkgs, ... }:
    let
      systems = [
        "x86_64-linux"
        "aarch64-linux"
        "x86_64-darwin"
        "aarch64-darwin"
      ];

      forAllSystems = f:
        nixpkgs.lib.genAttrs systems (system:
          f {
            pkgs = import nixpkgs { inherit system; };
          });
    in
    {
      devShells = forAllSystems ({ pkgs }:
        let
          darwinFrameworks = pkgs.lib.optionals pkgs.stdenv.isDarwin [
            pkgs.darwin.apple_sdk.frameworks.CoreServices
            pkgs.darwin.apple_sdk.frameworks.Security
            pkgs.darwin.apple_sdk.frameworks.SystemConfiguration
          ];
        in
        {
          default = pkgs.mkShell {
            packages = [
              pkgs.cargo
              pkgs.clippy
              pkgs.openssl
              pkgs.pkg-config
              pkgs.rust-analyzer
              pkgs.rustc
              pkgs.rustfmt
            ] ++ darwinFrameworks;

            shellHook = ''
              export CARGO_INSTALL_ROOT="''${CARGO_INSTALL_ROOT:-$HOME/.cargo}"
              export PATH="$CARGO_INSTALL_ROOT/bin:$PATH"

              if ! command -v tvc >/dev/null 2>&1; then
                echo "Installing tvc with cargo..."
                cargo install tvc
              fi

              echo "Rust dev shell ready."
            '';
          };
        });
    };
}
