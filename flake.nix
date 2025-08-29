{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = {
    nixpkgs,
    flake-utils,
    ...
  }:
    flake-utils.lib.eachDefaultSystem
    (
      system: let
        pkgs = import nixpkgs {system = system;};
        inherit (pkgs) glibcLocales;
        inherit (pkgs.stdenv) isLinux;
        inherit (pkgs.lib) optionalString;

        beamPkgs = with pkgs.beam_minimal; packagesWith interpreters.erlang_28;
        erlang = beamPkgs.erlang;
      in {
        formatter = pkgs.alejandra;

        devShells.default = pkgs.mkShell {
          packages = with pkgs;
            [erlang
             nil
             beam27Packages.erlang-ls
             emacs30-pgtk
             inetutils
             agda
             ccls
             coreutils-prefixed];

          LOCALE_ARCHIVE = optionalString isLinux "${glibcLocales}/lib/locale/locale-archive";
          LANG = "en_US.UTF-8";

          ERL_INCLUDE_PATH = "${erlang}/lib/erlang/usr/include";
        };
      }
    );
}
