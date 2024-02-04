{
  description =
    "Isabelle2022 with a better LSP integration (specifically useful for emacs)";

  inputs = {
    nixpkgs.url = "nixpkgs/nixos-23.11";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    let
      systems = with flake-utils.lib;
        [
          system.x86_64-linux
          # Sorry if you are on any other system, but we require some packages which
          # can't be installed there.
        ];
    in flake-utils.lib.eachSystem systems (system:
      let
        pkgs = import nixpkgs { inherit system; };
        polyml = pkgs.callPackage ./polyml.nix { };
        isabelle = pkgs.callPackage ./isabelle.nix { inherit polyml; };
        # Create a fake "emacs" executable which sets the correct path to the LSP server at startup.
      in {
        formatter = pkgs.nixfmt;

        packages = {
          inherit isabelle polyml;
          isabelle-afp = pkgs.callPackage ./afp.nix { };
          isabelle-llvm = pkgs.callPackage ./llvm.nix { };
        };
      }) // {
        lib = import ./lib.nix self;
      };
}
