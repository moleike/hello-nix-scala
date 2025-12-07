# This flake is heavily indebted to the flake template in the sbt-derivation project:
# https://github.com/zaninime/sbt-derivation/blob/92d6d6d825e3f6ae5642d1cce8ff571c3368aaf7/templates/cli-app/flake.nix
{
  description = "Scala example flake for Zero to Nix";

  # Flake inputs
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.05";
    flake-utils.url = "github:numtide/flake-utils";
    sbt = {
      url = "github:zaninime/sbt-derivation";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-utils.follows = "flake-utils";
    };
  };

  # Flake outputs
  outputs = { self, nixpkgs, sbt, flake-utils, ... }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        name = "hello-nix-scala";
        version = "0.1.0";

        pkgs = import nixpkgs {
          inherit system;
        };

        jre = pkgs.jre_minimal.override {
          modules = [
            "java.base"
            "java.se"
            "java.xml"
            "jdk.unsupported"
          ];
          jdk = pkgs.jdk_headless;
        };

        getDepsSha256 = { system }:
          let
            hash = {
              "aarch64-darwin" = "sha256-QzQ+seWSyhyCXvPoUTf9Bk0JVcooM9Xn6QXiOHBYL1I=";
              "aarch64-linux" = "sha256-txBzKHePjBozIm7VtzzXUTrTNz//F19BfaeAGkR6b2M=";
            };
          in hash.${system};

      in
      {
        packages.default = sbt.mkSbtDerivation.${system} {
          pname = name;
          inherit version;
          src = ./.;
          nativeBuildInputs = with pkgs; [makeWrapper];
          buildInputs = with pkgs; [jre];
          depsSha256 = getDepsSha256 { inherit system; };
          buildPhase = "sbt assembly";
          installPhase = "install -T -D -m755 target/${name}.jar $out/bin/${name}";
          postFixup = ''
            wrapProgram $out/bin/${name} \
              --prefix PATH : ${nixpkgs.lib.makeBinPath [ jre ]}
          '';
        };
      }
    );
}
