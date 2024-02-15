{
  description =
    "Isabelle2022 with a better LSP integration (specifically useful for emacs)";

  inputs = {
    nixpkgs.url = "nixpkgs/nixos-23.11";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    let
      systems = with flake-utils.lib; [ system.x86_64-linux ];
    in flake-utils.lib.eachSystem systems (system:
      let
        pkgs = import nixpkgs { inherit system; };
        inherit (pkgs) lib;
      in {
        formatter = pkgs.nixfmt;

        packages = rec {
          default = isabelle;
          isabelle = pkgs.callPackage ./isabelle.nix {
            inherit polyml;
          };
          polyml = pkgs.polyml.overrideAttrs (old: {
            configureFlags = old.configureFlags ++ [ "--enable-intinf-as-int" ];
          });
        };
      });
}
