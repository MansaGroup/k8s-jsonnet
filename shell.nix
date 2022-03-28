{ system ? builtins.currentSystem }:
let
  pkgs = import
    (builtins.fetchTarball {
      name = "nixos-21.05";
      url = "https://github.com/NixOS/nixpkgs/archive/21.05.tar.gz";
      sha256 = "1ckzhh24mgz6jd1xhfgx0i9mijk6xjqxwsshnvq789xsavrmsc36";
    })
    { };

  voodoo = import
    (builtins.fetchTarball {
      name = "voodoo-0.1.1";
      url = "https://github.com/VoodooTeam/devops-nix-pkgs/archive/refs/tags/v0.1.1.tar.gz";
      sha256 = "1jxw6daiw8glpsq82gr29vdzmzvncr8vqa8rl6da5p26gbj6pxnn";
    })
    { inherit pkgs system; };
in
pkgs.mkShell {
  buildInputs =
    [
      pkgs.go-jsonnet
      pkgs.jq
      pkgs.yq-go
      pkgs.kubeval
      pkgs.gnumake

      voodoo.bats_1_3_0
      voodoo.polaris_4_0_4
    ];
}
