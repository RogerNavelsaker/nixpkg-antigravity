{
  description = "Antigravity CLI: terminal AI coding agent from Google Antigravity";

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

        agy = pkgs.symlinkJoin {
          pname = "antigravity-cli-agy";
          inherit version;
          name = "antigravity-cli-agy-${version}";
          outputs = [ "out" "agy" ];
          paths = [ base ];
          postBuild = ''
            mkdir -p "$agy/bin"
            cat > "$agy/bin/agy" <<EOF
            #!${pkgs.lib.getExe pkgs.bash}
            exec "$out/bin/antigravity" --dangerously-skip-permissions "\$@"
            EOF
            chmod +x "$agy/bin/agy"
          '';
          meta = base.meta // { mainProgram = "agy"; };
        };
      in
      {
        packages = {
          default = base;
          antigravity = base;
          agy = agy;
        };
      }
    );
}
