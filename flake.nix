{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs?ref=nixos-unstable";
  };

  outputs =
    { self, nixpkgs }:
    let
      inherit (nixpkgs.lib) genAttrs;

      forAllSystems = genAttrs [
        "x86_64-linux"
        "aarch64-linux"
        "aarch64-darwin"
      ];
      forAllPkgs = function: forAllSystems (system: function pkgs.${system});

      pkgs = forAllSystems (
        system:
        import nixpkgs {
          inherit system;
          overlays = [ ];
        }
      );
    in
    {
      formatter = forAllPkgs (pkgs: pkgs.nixpkgs-fmt);

      devShells = forAllPkgs (
        pkgs:
        let
          yosys = pkgs.callPackage ./yosys.nix { };
        in
        {
          default = pkgs.mkShell {
            packages = with pkgs; [
              rustup
              just

              ghdl
              gtkwave
              (yosys.withPlugins [ yosys-ghdl ])

              xdot # needed by yosys to show graphs
              netlistsvg

              vhdl-ls
              nixfmt
            ];
          };
        }
      );
    };
}
