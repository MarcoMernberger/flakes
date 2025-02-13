{
  description = "A very basic flake";

  inputs.nixpkgs.url = "nixpkgs/nixos-22.05";

  outputs = { self, nixpkgs }: {
  
    defaultPackage.x86_64-linux =
      # Notice the reference to nixpkgs here.
      with import nixpkgs { system = "x86_64-linux"; inherit system; };
      stdenv.mkDerivation rec {
        name = "gsea";
        major = "4.3";    
        version = "4.3.2";
        src = fetchzip {
          url = "https://data.broadinstitute.org/gsea-msigdb/gsea/software/desktop/${major}/GSEA_Linux_${version}.zip";
          sha256 = "T5b8pp91wf5TuRQXBy0QqdzYS9AJBxy4Q84RLUSlqGU=";
        };
        buildPhase = "";
        installPhase = ''
          mkdir $out/bin -p
          cp * $out/bin -r
        '';
      };
  };
}