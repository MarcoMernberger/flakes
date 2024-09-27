{
  description = "flake for ngmerge";

  # Nixpkgs / NixOS version to use.
  inputs.nixpkgs.url = "nixpkgs/nixos-21.11";
  # this line assume that you also have nixpkgs as an input

  outputs = { self, nixpkgs }:
    let

      # Generate a user-friendly version number.
      #version = builtins.substring 0 8 self.lastModifiedDate;

      supportedSystems = [
        "x86_64-linux"
        "x86_64-darwin"
        "aarch64-linux"
        "aarch64-darwin"
      ];
      forAllSystems = nixpkgs.lib.genAttrs supportedSystems;
      nixpkgsFor = forAllSystems (system: import nixpkgs { inherit system; });

    in {

      # package.
      defaultPackage = forAllSystems (system:
        let pkgs = nixpkgsFor.${system};
        in pkgs.stdenv.mkDerivation rec {
          pname = "ngmerge";
          version = "0.3";
          src = pkgs.fetchFromGitHub {
            owner = "jsh58";
            repo = "NGmerge";
            rev = "bf260e591114fb1045e80ec5fa2cc3e663b2e19c";
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
            make
          '';
          installPhase = ''
          '';
          buildInputs = [
            ncurses
            zlib
          ];
        });
    };
}