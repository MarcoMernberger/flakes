{
  description = "flake for GATK package";

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
          pname = "GATK";
          version = "4.2.6.1";
          src = pkgs.fetchzip {
            url =
              "https://github.com/broadinstitute/gatk/releases/download/${version}/gatk-${version}.zip";
            sha256 =
              "sha256:1125cfc862301d437310506c8774d36c3a90d00d52c7b5d6b59dac7241203628";
          };
          autoPatchelfIgnoreMissingDeps=true; # libidn.11 - but nixpkgs has .12
          nativeBuildInputs = with pkgs; [
            autoPatchelfHook
            zlib
          ];
          buildPhase = "";
          installPhase = ''
            mkdir $out/bin -p
            cp * $out/bin -r
          '';
        });
    };
}