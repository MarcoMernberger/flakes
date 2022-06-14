{
  description = "flake for VarScan2";

  # Nixpkgs / NixOS version to use.
  inputs.nixpkgs.url = "nixpkgs/nixos-21.11";
  # this line assume that you also have nixpkgs as an input

  outputs = { self, nixpkgs }:
    let

      # Generate a user-friendly version number.
      #version = builtins.substring 0 8 self.lastModifiedDate;

      supportedSystems = [
        "x86_64-linux"
      ]; # "x86_64-darwin" "aarch64-linux" "aarch64-darwin" ]; guess we could adjust the url...
      forAllSystems = nixpkgs.lib.genAttrs supportedSystems;
      nixpkgsFor = forAllSystems (system: import nixpkgs { inherit system; });

    in {

      # package.
      defaultPackage = forAllSystems (system:
        let pkgs = nixpkgsFor.${system};
        in pkgs.stdenv.mkDerivation rec {
          pname = "VarScan2";
          version = "2.4.4";
          src = pkgs.fetchurl {
            url =
              "https://github.com/dkoboldt/varscan/raw/master/VarScan.v${version}.jar";
            sha256 =
              "sha256:fb23b72ab676fb5a89bd02091c2b6c9aff210b96bee04d9dee6aef4d8b72814d";
            curlOpts = "-L -o VarScan.v${version}.jar";
          };
          autoPatchelfIgnoreMissingDeps=true; # libidn.11 - but nixpkgs has .12
          nativeBuildInputs = with pkgs; [
            autoPatchelfHook
            zlib
          ];
          dontUnpack = true;
          buildPhase = "";
          installPhase = ''
            mkdir $src/bin -p
            cp * $src/bin -r
          '';
        });
    };
}