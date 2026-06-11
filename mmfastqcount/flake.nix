{
  description = "mmfqcount packaged from GitHub";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/release-25.11";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = {
    self,
    nixpkgs,
    flake-utils,
  }:
    flake-utils.lib.eachDefaultSystem (system: let
      pkgs = import nixpkgs {inherit system;};
    in {
      packages.default = pkgs.rustPlatform.buildRustPackage {
        pname = "mmfqcount";
        version = "0.1.0";

        src = pkgs.fetchFromGitHub {
          owner = "MarcoMernberger";
          repo = "mmfqcount";
          rev = "main"; # besser: tag später!
          sha256 = pkgs.lib.fakeSha256;
        };

        cargoLock = {
          lockFile = builtins.fetchTarball {
            url = "https://raw.githubusercontent.com/MarcoMernberger/mmfqcount/main/Cargo.lock";
            sha256 = pkgs.lib.fakeSha256;
          };
        };
      };

      apps.default = {
        type = "app";
        program = "${self.packages.${system}.default}/bin/mmfqcount";
      };
    });
}
