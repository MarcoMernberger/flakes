{
  description = "flake for MAGeCK";

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
          pname = "MAGeCK";
          version = "0.5.9.5";
          src = pkgs.fetchurl {
            url =
              "mirror://sourceforge/mageck/0.5/mageck-${version}.tar.gz";
            sha256 =
              "sha256:b06a18036da63959cd7751911a46727aefe2fb1d8dd79d95043c3e3bdaf1d93a";
            curlOpts = "-L -o mageck-${version}.tar.gz";
          };
          autoPatchelfIgnoreMissingDeps=true; # libidn.11 - but nixpkgs has .12
          nativeBuildInputs = with pkgs; [
            autoPatchelfHook
            zlib
          ];
          dontUnpack = false;
          buildPhase = "";
          installPhase = ''
            mv liulab-mageck-c491c3874dca mageck-${version}
            cd mageck-${version}
            python setup.py install
          '';
        });
    };
}