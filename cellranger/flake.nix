{
  description = "Flake for Cell Ranger by 10x Genomics";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs";
  };

  outputs = { self, nixpkgs }: 
    let
      system = "x86_64-linux";  # Adjust for your architecture
      pkgs = import nixpkgs {
        inherit system;
        config.allowUnfree = true;
        };
    in {
      packages.${system}.cellranger = pkgs.stdenv.mkDerivation rec {
        pname = "cellranger";
        version = "9.0.1";  # Adjust to the version you downloaded

        src = pkgs.fetchurl {
          url = "https://cf.10xgenomics.com/releases/cell-exp/cellranger-9.0.1.tar.gz?Expires=1739410897&Key-Pair-Id=APKAI7S6A5RYOXBWRPDA&Signature=U3YMHtYiqhb-dsni2eaZQb96Bd45NC4sUMojjOCmjOsbGB2upSlcufG2O2T6WKgma~bO9zxXXW~Estfql9m~SKIcISzXeY8A3AfxDkj7cSv-V2jY5TIsVfqF6zq72sw0Q-Fref~8MtgTJQCquTEW24TcBae05V~VxUMC~8HPBnZFCbKZNT4Few8wbenSxHzekta24kp8dXqo4tLHl9p5zZxLpq-vaetaODsBJqIJcb8TAiY3BbH6IhlbMMC7TZ3UzRWuQ084Ofyi9lzIaxIckzW0P~BoVefIHftDxwfko0d6QX2sed9C5fqR7oBufITccsfIK-MynQGh3E4fDMYfwQ__";  # Update with the actual path
          sha256 = "sha256-1MXAE44A3I2EVHQC15zuU0o9MJn9fCZxJi6dOvZK4Ro=";
        };

        nativeBuildInputs = [ pkgs.autoPatchelfHook ];
        buildInputs = [
            pkgs.zlib
            pkgs.bzip2
            pkgs.xz
            pkgs.glibc
            pkgs.python3
            pkgs.xorg.libX11  # Corrected libX11 package name
            pkgs.readline  # Fixes missing libreadline.so.8
            pkgs.libxcrypt  # Fixes missing libcrypt.so.1
            pkgs.lzo       # Fixes missing liblzo2.so.2
        ];
        unpackPhase = ''
            echo "Renaming source file..."
            cp $src source.tar.gz
            tar -xvzf source.tar.gz
            cd cellranger-9.0.1  # Adjust if the extracted folder has a different name
            '';
        dontBuild = true;
        dontStrip = true;
        installPhase = ''
            mkdir -p $out/bin
            cp -r * $out/

            # Ensure libcrypt.so.1 is available by creating a symlink
            mkdir -p $out/lib
            ln -sf ${pkgs.libxcrypt.out}/lib/libcrypt.so.2 $out/lib/libcrypt.so.1

            # Ensure executables find the new library
            patchelf --set-rpath $out/lib:$out/lib64 $(find $out/bin -type f || true)
            patchelf --set-rpath $out/lib:$out/lib64 $(find $out/external -type f || true)

            ln -sf $out/cellranger $out/bin/cellranger
            '';
        meta = with pkgs.lib; {
          description = "Cell Ranger - Single Cell Data Analysis from 10x Genomics";
          homepage = "https://www.10xgenomics.com";
          license = licenses.unfree;
          platforms = [ "x86_64-linux" ];
        };
      };

      defaultPackage.${system} = self.packages.${system}.cellranger;
    };
}