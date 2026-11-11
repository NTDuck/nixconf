# omp-antigravity-acp-provider — declarative omp plugin store entry.
#
# Google Antigravity ACP provider for omp (SenCha930511's fork of
# zacbemis/pi-antigravity-acp-provider), installed via omp's npm plugin
# store (~/.omp/plugins). Declarative materialization:
#   - the npm tarball is dependency-free (dependencies: null; bare
#     imports like typebox/@modelcontextprotocol/sdk are rewritten by
#     omp's extension loader onto its own bundled modules — the store's
#     bun.lock carries only the one package)
#   - so the store is exactly: package.json (workspace dep), bun.lock,
#     omp-plugins.lock.json (enable state), node_modules/<pkg>
# All three files are HM-managed (force = true, self-heal over the
# imperative `omp plugin install` state this replaced, 2026-11-11).
# Plugin upgrades: bump the version + hashes here, then re-switch.
# `omp plugin upgrade` no longer applies (RO store paths).
{
  den,
  ...
}: let
  pluginVersion = "0.1.42";
  ompAntigravityAcpProvider = {pkgs}: pkgs.fetchzip {
    url = "https://registry.npmjs.org/omp-antigravity-acp-provider/-/omp-antigravity-acp-provider-${pluginVersion}.tgz";
    hash = "sha256-jIHqusjyo+NyRQ0U6tTTWdGWOFDnfrZoUQtrZ4fhv+Y=";
    # npm tarballs have a package/ root; fetchzip strips it only with
    # stripRoot (default true) — keep default, source is the unpacked tree.
  };
in {
  den.aspects.dev.agentics.harnesses.omp-antigravity-acp-plugin = {
    homeManager = {
      pkgs,
      lib,
      ...
    }: {
      home.file.".omp/plugins/node_modules/omp-antigravity-acp-provider" = {
        source = ompAntigravityAcpProvider { inherit pkgs; };
        force = true;
      };
      home.file.".omp/plugins/package.json" = {
        text = builtins.toJSON {
          name = "omp-plugins";
          private = true;
          dependencies = {
            "omp-antigravity-acp-provider" = "npm:omp-antigravity-acp-provider@^${pluginVersion}";
          };
        };
        force = true;
      };
      # Enable state (omp plugin list / doctor read this; enableFeatures).
      home.file.".omp/plugins/omp-plugins.lock.json" = {
        text = builtins.toJSON {
          plugins = {
            "omp-antigravity-acp-provider" = {
              version = pluginVersion;
              enabledFeatures = null;
              enabled = true;
            };
          };
          settings = {};
        };
        force = true;
      };
    };
  };
}
