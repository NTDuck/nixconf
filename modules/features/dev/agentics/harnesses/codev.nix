{...}: {
  den.aspects.dev.agentics.harnesses.codev = {
    nixos = {
      pkgs,
      lib,
      ...
    }: let
      codevVersion = "1.18.4-11";
      codevSources = {
        x86_64-linux = {
          pkgName = "codev-code-linux-x64";
          hash = "sha256-Iass12pHr9E1pJImvn3AQOjN2K26vtuOHEvqdbPiRXQ=";
        };
        aarch64-linux = {
          pkgName = "codev-code-linux-arm64";
          hash = "sha256-U/TIbt5skWyPjecT0iJ3/USQp+OZN7irphl5F4LM+Fg=";
        };
        aarch64-darwin = {
          pkgName = "codev-code-darwin-arm64";
          hash = "sha256-DncbMzCXwJh6Zu66T/9aEegJWdWNVMla186tDvMbn+4=";
        };
        x86_64-darwin = {
          pkgName = "codev-code-darwin-x64";
          hash = "sha256-Ul1djN32bVN3SN2zPwqjzw1PUQLFM8hWSbV/Eqs0SXI=";
        };
      };

      systemSource =
        codevSources.${pkgs.stdenv.hostPlatform.system}
        or (throw "Unsupported system for codev-code: ${pkgs.stdenv.hostPlatform.system}");

      codev-code = pkgs.stdenv.mkDerivation {
        pname = "codev-code";
        version = codevVersion;

        src = pkgs.fetchurl {
          url = "https://registry.npmjs.org/${systemSource.pkgName}/-/${systemSource.pkgName}-${codevVersion}.tgz";
          inherit (systemSource) hash;
        };

        nativeBuildInputs = lib.optionals pkgs.stdenv.isLinux [
          pkgs.autoPatchelfHook
        ];

        buildInputs = lib.optionals pkgs.stdenv.isLinux [
          pkgs.stdenv.cc.cc.lib
          pkgs.zlib
        ];

        dontStrip = true;

        installPhase = ''
          runHook preInstall
          install -Dm755 bin/codev $out/bin/codev
          runHook postInstall
        '';

        meta = {
          description = "CoDev Code — AI coding agent TUI (OpenCode fork)";
          homepage = "https://github.com/mnguyencuny/codev";
          license = lib.licenses.mit;
          mainProgram = "codev";
          platforms = builtins.attrNames codevSources;
        };
      };

      codevhub = pkgs.unstable.buildNpmPackage rec {
        pname = "codev-ai";
        version = "0.5.17";

        src = pkgs.fetchurl {
          url = "https://registry.npmjs.org/codev-ai/-/codev-ai-${version}.tgz";
          hash = "sha256-IqfzdXYIAwyPnpANBWo/dmCkwlkbFtMDfQYReleW7/4=";
        };

        postPatch = ''
          cp ${./codev-package-lock.json} package-lock.json
          ${pkgs.jq}/bin/jq '.scripts = {}' package.json > package.json.tmp && mv package.json.tmp package.json
        '';

        npmDepsHash = "sha256-9UN9A0piPO+gX8Lpq2ULXRyPl4Q8XDoAmcDJVVgQllc=";
        dontNpmBuild = true;

        nativeBuildInputs = [pkgs.makeWrapper];

        postInstall = ''
          wrapProgram $out/bin/codevhub \
            --prefix PATH : "${lib.makeBinPath [codev-code]}" \
            --set-default NODE_USE_SYSTEM_CA 1 \
            --set-default NODE_USE_ENV_PROXY 1
        '';

        meta = {
          description = "CoDev — AI Coding Agent Hub. Install, configure, and manage multiple AI coding agents";
          homepage = "https://github.com/mnguyencuny/codev";
          license = lib.licenses.mit;
          mainProgram = "codevhub";
          platforms = lib.platforms.all;
        };
      };
    in {
      environment.systemPackages = [
        codev-code
        codevhub
      ];
    };
  };
}
