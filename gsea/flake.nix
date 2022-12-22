{
  description = "flake for GSEA";

  # Nixpkgs / NixOS version to use.
  inputs.nixpkgs.url = "nixpkgs/nixos-22.05";
  # this line assume that you also have nixpkgs as an input
  
  outputs = { self, nixpkgs }:
    let  # define local variables  -  the value of let expression is the value after the in below

      supportedSystems = ["x86_64-linux"]; # supportedSystems is a local variable known "in" ... 
      forAllSystems = nixpkgs.lib.genAttrs supportedSystems;
      nixpkgsFor = forAllSystems (system: import nixpkgs { inherit system; });

    in {

      # package.
      defaultPackage = forAllSystems (system:
        let pkgs = nixpkgsFor.${system};
        in pkgs.stdenv.mkDerivation rec {
          name = "GSEA_4.0.3";
          pname = "GSEA";
          version = "4.0.3";
          major = "4.0";
          src = pkgs.fetchzip {
            url =
              "https://data.broadinstitute.org/gsea-msigdb/gsea/software/desktop/${major}/GSEA_${version}.zip";
              sha256 = "T5b8pp91wf5TuRQXBy0QqdzYS9AJBxy4Q84RLUSlqGU=";
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