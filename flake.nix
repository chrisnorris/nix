{
  inputs.nixpkgs.url = "github:nixos/nixpkgs?ref=nixpkgs-unstable";

  outputs = {
    self,
    nixpkgs,
    ...
  }: let
    pkgs = import nixpkgs {system = "x86_64-darwin";};
    inherit (pkgs) glibcLocales;
    inherit (pkgs.stdenv) isLinux;
    inherit (pkgs.lib) optionalString;

    beamPkgs = with pkgs.beam_minimal; packagesWith interpreters.erlang_28;
    erlang = beamPkgs.erlang;
  in {
    formatter.x86_64-darwin = pkgs.alejandra;

    devShells.x86_64-darwin.default = pkgs.mkShell {
      packages = [erlang pkgs.nil pkgs.beam27Packages.erlang-ls pkgs.emacs30-pgtk pkgs.inetutils pkgs.agda pkgs.ccls];

      LOCALE_ARCHIVE = optionalString isLinux "${glibcLocales}/lib/locale/locale-archive";
      LANG = "en_US.UTF-8";

      ERL_INCLUDE_PATH = "${erlang}/lib/erlang/usr/include";
    };
  };
}
