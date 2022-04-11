{
  description = "flake for gdc-download";

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
          pname = "gdc";
          version = "1.6.1";
          src = pkgs.fetchzip {
            url =
              "https://gdc.cancer.gov/files/public/file/gdc-client_v${version}_Ubuntu_x64.zip";
            sha256 =
              "sha256:03f4ah49mlkvy6l3ywh1y1d3w19dpnifavl5slhq9wq0pdknwmh1";
          };
          autoPatchelfIgnoreMissingDeps=true; # libidn.11 - but nixpkgs has .12
          nativeBuildInputs = with pkgs; [
            autoPatchelfHook
            zlib
          ];
          buildPhase = "";
          installPhase = ''
            mkdir $out/bin -p
            cp bin/* $out/bin -r
          '';
        });
    };
}