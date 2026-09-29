{
  description = "Antigravity CLI: terminal AI coding agent from Google Antigravity";

  nixConfig = {
    extra-substituters = [
      "https://cache.nixos.org"
      "https://nix-community.cachix.org"
      "https://rogernavelsaker.cachix.org"
      "https://nacosolutions.cachix.org"
    ];
    extra-trusted-public-keys = [
      "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      "rogernavelsaker.cachix.org-1:n1DtzMNhA9Rz4Kg3xlXOi/KceULu8VrMbs9WXyMFQNQ="
      "nacosolutions.cachix.org-1:JzCiW2CLcuLXtwOVAg3SlSK/kpqWbfSFEVenyKVUlug="
    ];
  };


  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs {
          inherit system;
          config.allowUnfree = true;
        };

        manifest = builtins.fromJSON (builtins.readFile ./sources.json);
        version = manifest.version;
        sources = manifest.sources;

        src = sources.${system} or (throw "Unsupported system: ${system}");

        base = pkgs.stdenv.mkDerivation {
          pname = "antigravity-cli";
          inherit version;

          outputs = [ "out" "agy" ];

          src = pkgs.fetchurl {
            inherit (src) url sha512;
          };

          sourceRoot = ".";

          nativeBuildInputs = pkgs.lib.optionals pkgs.stdenv.isLinux [
            pkgs.autoPatchelfHook
          ];

          buildInputs = pkgs.lib.optionals pkgs.stdenv.isLinux [
            pkgs.stdenv.cc.cc.lib
            pkgs.zlib
          ];

          installPhase = ''
            runHook preInstall
            mkdir -p $out/bin $out/share/antigravity
            install -m 0755 antigravity $out/share/antigravity/antigravity
            cat > $out/bin/antigravity <<EOF
            #!${pkgs.lib.getExe pkgs.bash}
            exec "$out/share/antigravity/antigravity" "\$@"
            EOF
            chmod +x $out/bin/antigravity

            mkdir -p $agy/bin
            cat > $agy/bin/agy <<EOF
            #!${pkgs.lib.getExe pkgs.bash}
            exec "$out/bin/antigravity" --dangerously-skip-permissions "\$@"
            EOF
            chmod +x $agy/bin/agy
            runHook postInstall
          '';

          meta = with pkgs.lib; {
            description = "Antigravity CLI: terminal AI coding agent from Google Antigravity";
            homepage = "https://antigravity.google/product/antigravity-cli";
            license = licenses.unfree;
            platforms = builtins.attrNames sources;
            mainProgram = "antigravity";
            maintainers = [ ];
            sourceProvenance = [ sourceTypes.binaryNativeCode ];
          };
        };

      in
      {
        packages = {
          default = base;
          antigravity = base;
          agy = base.agy;
        };
      }
    );
}