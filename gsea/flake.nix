{
  description = "flake for GSEA";

  # Nixpkgs / NixOS version to use.
  inputs.nixpkgs.url = "nixpkgs/nixos-22.05";
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
          pname = "GSEA";
          version = "4.3.2";
          major = "4.3";
          src = pkgs.fetchzip {
            url =
              "http://www.gsea-msigdb.org/gsea/msigdb/download_file.jsp?filePath=/gsea/software/desktop/${major}/GSEA_Linux_${version}.zip";
            sha256 =!
              "sha256:yG/3NgbrN+rKMvxLS8k3UD5wWOcQtyj9tGq47g7VVEI=";
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