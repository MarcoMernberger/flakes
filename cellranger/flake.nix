{
  description = "Cellranger";

  inputs.nixpkgs.url = "nixpkgs/nixos-21.05"; # doesn't matter much

  outputs = { self, nixpkgs }:
    let

      # Generate a user-friendly version number.
      #version = builtins.substring 0 8 self.lastModifiedDate;

      supportedSystems = [
        "x86_64-linux"
        "x86_64-darwin"
        "aarch64-linux"
        "aarch64-darwin"
      ]; # it's java afterall
      forAllSystems = nixpkgs.lib.genAttrs supportedSystems;
      nixpkgsFor = forAllSystems (system: import nixpkgs { inherit system; });

    in {

      # package.
      defaultPackage = forAllSystems (system:
        let pkgs = nixpkgsFor.${system};
        in pkgs.stdenv.mkDerivation rec {
          pname = "cellranger";
          version = "9.0.1";
          src = pkgs.fetchurl {
            url =
              "https://cf.10xgenomics.com/releases/cell-exp/cellranger-9.0.1.tar.gz?Expires=1739410897&Key-Pair-Id=APKAI7S6A5RYOXBWRPDA&Signature=U3YMHtYiqhb-dsni2eaZQb96Bd45NC4sUMojjOCmjOsbGB2upSlcufG2O2T6WKgma~bO9zxXXW~Estfql9m~SKIcISzXeY8A3AfxDkj7cSv-V2jY5TIsVfqF6zq72sw0Q-Fref~8MtgTJQCquTEW24TcBae05V~VxUMC~8HPBnZFCbKZNT4Few8wbenSxHzekta24kp8dXqo4tLHl9p5zZxLpq-vaetaODsBJqIJcb8TAiY3BbH6IhlbMMC7TZ3UzRWuQ084Ofyi9lzIaxIckzW0P~BoVefIHftDxwfko0d6QX2sed9C5fqR7oBufITccsfIK-MynQGh3E4fDMYfwQ__";
            sha256 = "";
          };
          nativeBuildInputs = with pkgs; [zlib];
          installPhase = ''
          '';
        });
    };
}