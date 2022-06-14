{
  description = "flake for Variant Effekt Predictor";

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
          pname = "VEP";
          version = "4.2.6.1";
          src = pkgs.fetchgit {
            url = "https://github.com/Ensembl/ensembl-vep.git";
            sha256 = "sha256:lyRt3cqsHdCFBeAdj9wgXorxi/7h1jgVX1cDWyePoBk=";
          };
          autoPatchelfIgnoreMissingDeps=true; # libidn.11 - but nixpkgs has .12
          nativeBuildInputs = with pkgs; [
            autoPatchelfHook
            zlib
            perl534Packages.DBI
            perl534Packages.ArchiveZip 
          ];
          buildPhase = ''
          '';
          installPhase = ''
            ls -al
            pwd
            perl INSTALL.pl
          '';

        });
    };
}