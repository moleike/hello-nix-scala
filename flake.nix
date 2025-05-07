# This flake is heavily indebted to the flake template in the sbt-derivation project:
# https://github.com/zaninime/sbt-derivation/blob/92d6d6d825e3f6ae5642d1cce8ff571c3368aaf7/templates/cli-app/flake.nix
{
  description = "Scala example flake for Zero to Nix";

  # Flake inputs
  inputs = {
    nixpkgs.url = "https://flakehub.com/f/NixOS/nixpkgs/0.2305.491812";
    flake-utils.url = github:numtide/flake-utils;
    sbt = {
      url = "github:zaninime/sbt-derivation";
      inputs.nixpkgs.follows = "nixpkgs";
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

      in
      {
        # Package outputs
        packages = {
          default = sbt.mkSbtDerivation.${system} {
            pname = name;
            inherit version;
            depsSha256 = "sha256-xSKC0PRl/8OQwFtxUycNGWenagQOTHW3R5CeUimdZes=";
            src = ./.;
            depsWarmupCommand = ''
              sbt 'managedClasspath; compilers'
            '';
            startScript = ''
              #!${pkgs.runtimeShell}

              exec ${jre}/bin/java \
                ''${JAVA_OPTS:-} \
                -jar \
                "${placeholder "out"}/share/java/${name}.jar" \
                "$@"
            '';
            buildPhase = ''
              sbt assembly
            '';
            installPhase = ''
              mkdir -p $out/share/java
              cp target/scala-3.3.3/${name}.jar $_
              install -T -D -m755 $startScriptPath $out/bin/${name}
            '';
            passAsFile = [ "startScript" ];
          };
        };
      }
    );
}
