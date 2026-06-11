{
  description = "Anysnake2 generated flake";
  inputs = rec {
    flake-utils = {
      url = "github:numtide/flake-utils/11707dc2f618dd54ca8739b309ec4fc024de578b";
    };
    nixpkgs = {
      url = "github:NixOS/nixpkgs/25.05";
    };
    uv2nix = {
      #url = "github:adisbladis/uv2nix/05b0c148bc53aebc6a906b6d0ac41dde5954cd47";
      url = "github:adisbladis/uv2nix";
    };

    pyproject-build-systems = {
      url = "github:pyproject-nix/build-system-pkgs";
      inputs.uv2nix.follows = "uv2nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # uv2nix_override_collection = {
    #   #url = "github:TyberiusPrime/uv2nix_hammer_overrides/e53075de5587a33b3b68a809ea3124b615ab260c";
    #   url = "/home/finkernagel/upstream/uv2nix/uv2nix_hammer_overrides";
    # };
  };

  outputs = flake_inputs @ {
    self,
    flake-utils,
    nixpkgs,
    uv2nix,
    pyproject-build-systems,
    # uv2nix_override_collection,
  }:
    flake-utils.lib.eachDefaultSystem (
      system: let
        pkgs = import nixpkgs {
          inherit system overlays;
          config = {
            allowUnfree = false;
          };
        };
        R_tracked = null;
        interpreter = pkgs.python312;
        local_anysnake_overrides = final: prev: {
          umi-tools = prev.umi-tools.overrideAttrs (old: {
            preBuild = pkgs.lib.optionals (final.python.pythonAtLeast "3.12") ''
              #${final.cython}/bin/cython umi_tools/_dedup_umi.pyx
            '';
            nativeBuildInputs = old.nativeBuildInputs ++ (final.resolveBuildSystem {setuptools = [];});
            buildInputs = old.buildInputs or [] ++ [final.pysam];
            patches = [./umitools.patch];
          });
          pylingual = prev.pylingual.overrideAttrs (old: {
            nativeBuildInputs = old.nativeBuildInputs ++ (final.resolveBuildSystem {poetry-core = [];});
          });
          muscad = prev.muscad.overrideAttrs (old: {
            nativeBuildInputs = old.nativeBuildInputs ++ (final.resolveBuildSystem {poetry-core = [];});
          });
          izdvd = prev.izdvd.overrideAttrs (old: {
            nativeBuildInputs = old.nativeBuildInputs ++ (final.resolveBuildSystem {setuptools = [];});
          });
          nvidia-cufile = prev.nvidia-cufile.overrideAttrs (old: {
            autoPatchelfIgnoreMissingDeps = ["*"];
          });
          nvidia-nvshmem-cu13 = prev.nvidia-nvshmem-cu13.overrideAttrs (old: {
            autoPatchelfIgnoreMissingDeps = ["*"];
          });

          nvidia-cusparse = prev.nvidia-cusparse.overrideAttrs (old: {
            autoPatchelfIgnoreMissingDeps = ["*"];
          });

          nvidia-cusolver = prev.nvidia-cusolver.overrideAttrs (old: {
            autoPatchelfIgnoreMissingDeps = ["*"];
          });
          # torch = prev.torch.overrideAttrs (old: {
          #   autoPatchelfIgnoreMissingDeps = true;
          #   nativeBuildInputs =
          #     old.nativeBuildInputs
          #     ++ [
          #       pkgs.cudaPackages.libcusparse_lt
          #       pkgs.cudaPackages.libcufile
          #     ];
          # });
          # euclid3 = prev.euclid3.overrideAttrs (old: {
          #   nativeBuildInputs =
          #     old.nativeBuildInputs
          #     ++ (final.resolveBuildSystem {setuptools = [];});
          # });
          # plotnine = prev.plotnine.overrideAttrs (old: {
          #   src = pkgs.fetchFromGitHub {
          #     owner = "has2k1";
          #     repo = "plotnine";
          #     rev = "250ae83bc9bdd9ec32ccded781ff929e489d5229";
          #     hash = "sha256-3ImNLmZ8RhhqRGv/FtdjbHmdOtgQC7hjUsViEQYE8Ao";
          #   };
          # });
        };
        local_user_overrides = final: prev: {};
        overlay = workspace.mkPyprojectOverlay {sourcePreference = "wheel";};
        overlays = [(final: prev: {uv = uv2nix.packages."${system}".uv-bin;})];
        pyproject-nix = uv2nix.inputs.pyproject-nix;
        pyprojectOverrides = [
          #(uv2nix_override_collection.overrides_debug pkgs)
          local_anysnake_overrides
          local_user_overrides
        ];
        pythonSet =
          (pkgs.callPackage pyproject-nix.build.packages {
            python = interpreter;
          }).overrideScope
          (
            pkgs.lib.composeManyExtensions (
              [
                pyproject-build-systems.overlays.default
                overlay
              ]
              ++ pyprojectOverrides
            )
          );
        python_package = pythonSet.mkVirtualEnv "anysnake2-venv" spec;
        spec = {
          mypython = [];
        };
        workspace = uv2nix.lib.workspace.loadWorkspace {
          workspaceRoot = ./.;
        };
      in {
        packages = {
          default = python_package;
        };
      }
    );
}
