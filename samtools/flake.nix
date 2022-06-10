{
  description = "flake for samtools";

  # Nixpkgs / NixOS version to use.
  inputs.nixpkgs.url = "nixpkgs/nixos-21.11";
  # this line assume that you also have nixpkgs as an input

  outputs = { self, nixpkgs }:
    let

      # Generate a user-friendly version number.
      #version = builtins.substring 0 8 self.lastModifiedDate;

      supportedSystems = [
        "x86_64-linux"
      ];
      forAllSystems = nixpkgs.lib.genAttrs supportedSystems;
      nixpkgsFor = forAllSystems (system: import nixpkgs { inherit system; });

    in {

      # package.
      defaultPackage = forAllSystems (system:
        let pkgs = nixpkgsFor.${system};
        in pkgs.stdenv.mkDerivation rec {
          version = "1.5";
          pname = "samtools-${version}";
          src = pkgs.fetchurl {
          url = "https://github.com/samtools/samtools/releases/download/${version}/samtools-${version}.tar.bz2";
          sha256 = "1xidmv0jmfy7l0kb32hdnlshcxgzi1hmygvig0cqrq1fhckdlhl5";
          };
          autoPatchelfIgnoreMissingDeps=true; # libidn.11 - but nixpkgs has .12
          nativeBuildInputs = with pkgs; [
            autoPatchelfHook
            zlib
          ];
          configureFlags = [
            "--enable-plugins"
            "--enable-libcurl"
            "--disable-lzma"
          ];
          buildPhase = ''
            make all all-htslib
          '';
          installPhase = ''
            make install install-htslib
          '';
          buildInputs = [
            ncurses
            zlib
            bzip2
            curl
            python
            perl
          ];
        });
    };
}