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
  den.aspects.hp-probook-450g3-5CD8132YC3 = {
    nixos = {lib, ...}: {
      # The HP is a low-end host; keep compositor and application opacity
      # fully opaque so Mango does less blending work.
      stylix.opacity.applications = lib.mkForce 1.0;
    };

    provides.to-users.homeManager = {
      lib,
      pkgs,
      ...
    }: {
      programs.noctalia.settings = lib.mkForce lowEndNoctaliaSettings;

      wayland.windowManager.mango.settings = {
        monitorrule = lib.mkForce "name:^eDP-1$,width:1366,height:768,refresh:60,x:0,y:0,scale:1,vrr:0";

        blur = lib.mkForce 0;
        blur_layer = lib.mkForce 0;
        blur_params_radius = lib.mkForce 0;
        blur_params_num_passes = lib.mkForce 0;
        border_radius = lib.mkForce 4;

        focused_opacity = lib.mkForce 1.0;
        unfocused_opacity = lib.mkForce 1.0;

        animations = lib.mkForce 0;
        layer_animations = lib.mkForce 0;
        animation_fade_in = lib.mkForce 0;
        animation_fade_out = lib.mkForce 0;
        animation_type_open = lib.mkForce "none";
        animation_type_close = lib.mkForce "none";
        layer_animation_type_open = lib.mkForce "none";
        layer_animation_type_close = lib.mkForce "none";

        bind = lib.mkAfter [
          "SUPER,Return,spawn,${pkgs.unstable.foot}/bin/footclient"
        ];
      };
    };
  };
}
