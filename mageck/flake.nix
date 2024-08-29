{
  description = "flake for MAGeCK";

  # Nixpkgs / NixOS version to use.
  inputs.nixpkgs.url = "nixpkgs/nixos-21.11";
  # this line assume that you also have nixpkgs as an input

  outputs = {
    self,
    nixpkgs,
  }: let
    # Generate a user-friendly version number.
    #version = builtins.substring 0 8 self.lastModifiedDate;
    supportedSystems = [
      "x86_64-linux"
    ]; # "x86_64-darwin" "aarch64-linux" "aarch64-darwin" ]; guess we could adjust the url...
    forAllSystems = nixpkgs.lib.genAttrs supportedSystems;
    nixpkgsFor = forAllSystems (system: import nixpkgs {inherit system;});
  in {
    # package.
    defaultPackage = forAllSystems (system: let
      pkgs = nixpkgsFor.${system};
    in
      pkgs.python3Packages.buildPythonPackage rec {
        pname = "MAGeCK";
        version = "0.5.9.5";
        src = pkgs.fetchurl {
          url = "https://downloads.sourceforge.net/mageck/0.5/mageck-${version}.tar.gz";
          sha256 = "sha256-sGoYA22mOVnNd1GRGkZyeu/i+x2N152VBDw+O9rx2To=";
        };
        doCheck = false;
        propagatedBuildInputs = [
          pkgs.python3Packages.numpy
          pkgs.python3Packages.scipy
        ];
      });
  };
}