{
  den,
  inputs,
  ...
}: let
  lowEndNoctaliaSettings =
    builtins.replaceStrings
    [
      "\${inputs.self}"
      "blurred_desktop = true"
      "transition_on_startup = true"
      "cpu_poll_seconds = 1"
      "disk_poll_seconds = 1"
      "gpu_poll_seconds = 1"
      "memory_poll_seconds = 1"
      "network_poll_seconds = 1"
    ]
    [
      "${inputs.self}"
      "blurred_desktop = false"
      "transition_on_startup = false"
      "cpu_poll_seconds = 5"
      "disk_poll_seconds = 30"
      "gpu_poll_seconds = 30"
      "memory_poll_seconds = 5"
      "network_poll_seconds = 5"
    ]
    (builtins.readFile "${inputs.self}/modules/features/noctalia/noctalia-config.toml");
in {
  den.aspects.dell-latitude-E7270-H836QF2 = {
    nixos = {lib, ...}: {
      stylix.opacity.applications = lib.mkForce 1.0;
    };

    provides.to-users.homeManager = {lib, ...}: {
      programs.noctalia.settings = lib.mkForce lowEndNoctaliaSettings;
    };
  };
}
