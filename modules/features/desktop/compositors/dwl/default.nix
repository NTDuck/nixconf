{den, ...}: {
  # dwl: minimal wlroots compositor for the DELL streaming client. dwl ships
  # no runtime config UI — behavior is compiled into config.h, so we build it
  # with a custom configH (nixpkgs `dwl.override { configH = ...; }`).
  # Stock dwl defaults put dwmenu on MODKEY+p; ours swaps in dmenu-wayland
  # (dmenu-wl_run) and pins the keybindings below to mirror the mango setup
  # the DELL previously used (2026-09-17).
  den.aspects.desktop.compositors.dwl = {
    includes = [
      den.aspects.desktop.shells.zsh
    ];

    nixos = {
      pkgs,
      config,
      ...
    }: {
      # dmenu_wayland is built without an icon dependency and spawns via
      # dmenu-wl_run; `dwl` package itself must carry our config.h, so it is
      # overridden below (configH) and referenced by the session wrapper.
      programs.dwl = {
        enable = true;
        package = let
          # Keys/binds mirror the previous mango config on this host:
          # foot terminal, dmenu launcher, vim-style focus/hjkl, 9 tags,
          # quit = SUPER+SHIFT+e (mango muscle memory), volume/brightness
          # keys call wpctl (pipewire) and brightnessctl.
          configH = pkgs.writeText "dwl-config.h" ''
            #define COLOR(hex)    { ((hex >> 24) & 0xFF) / 255.0f, \
                                    ((hex >> 16) & 0xFF) / 255.0f, \
                                    ((hex >> 8) & 0xFF) / 255.0f, \
                                    (hex & 0xFF) / 255.0f }
            /* appearance */
            static const int sloppyfocus               = 1;
            static const int bypass_surface_visibility = 0;
            static const unsigned int borderpx         = 1;
            static const float rootcolor[]             = COLOR(0x16161eff);
            static const float bordercolor[]           = COLOR(0x2d4f67ff);
            static const float focuscolor[]            = COLOR(0x7fb4caff);
            static const float urgentcolor[]           = COLOR(0xffa066ff);
            static const float fullscreen_bg[]         = {0.0f, 0.0f, 0.0f, 1.0f};

            #define TAGCOUNT (9)

            static int log_level = WLR_ERROR;

            static const Rule rules[] = {
            	/* app_id             title       tags mask     isfloating   monitor */
            	{ "xdg-desktop-portal-gtk", NULL, 0, 1, -1 },
            	{ NULL, NULL, 0, 0, -1 },
            };

            static const Layout layouts[] = {
            	/* symbol     arrange function */
            	{ "[]=",      tile },
            	{ "><>",      NULL },
            	{ "[M]",      monocle },
            };

            static const MonitorRule monrules[] = {
            	{ NULL, 0.55f, 1, 1, &layouts[0], WL_OUTPUT_TRANSFORM_NORMAL, -1, -1 },
            };

            static const struct xkb_rule_names xkb_rules = {
            	.options = NULL,
            };

            static const int repeat_rate = 50;
            static const int repeat_delay = 150;

            /* Trackpad — mirrors the mango trackpad_* settings. */
            static const int tap_to_click = 1;
            static const int tap_and_drag = 1;
            static const int drag_lock = 1;
            static const int natural_scrolling = 1;
            static const int disable_while_typing = 1;
            static const int left_handed = 0;
            static const int middle_button_emulation = 0;
            static const enum libinput_config_scroll_method scroll_method = LIBINPUT_CONFIG_SCROLL_2FG;
            static const enum libinput_config_click_method click_method = LIBINPUT_CONFIG_CLICK_METHOD_CLICKFINGER;
            static const uint32_t send_events_mode = LIBINPUT_CONFIG_SEND_EVENTS_ENABLED;
            static const enum libinput_config_accel_profile accel_profile = LIBINPUT_CONFIG_ACCEL_PROFILE_ADAPTIVE;
            static const double accel_speed = 0.0;
            static const enum libinput_config_tap_button_map button_map = LIBINPUT_CONFIG_TAP_MAP_LRM;

            #define MODKEY WLR_MODIFIER_LOGO

            #define TAGKEYS(KEY,SKEY,TAG) \
            	{ MODKEY,                    KEY,            view,            {.ui = 1 << TAG} }, \
            	{ MODKEY|WLR_MODIFIER_CTRL,  KEY,            toggleview,      {.ui = 1 << TAG} }, \
            	{ MODKEY|WLR_MODIFIER_SHIFT, SKEY,           tag,             {.ui = 1 << TAG} }, \
            	{ MODKEY|WLR_MODIFIER_CTRL|WLR_MODIFIER_SHIFT,SKEY,toggletag, {.ui = 1 << TAG} }

            #define SHCMD(cmd) { .v = (const char*[]){ "/bin/sh", "-c", cmd, NULL } }

            static const char *termcmd[]  = { "footclient", NULL };
            static const char *menucmd[]  = { "dmenu-wl_run", NULL };

            static const Key keys[] = {
            	{ MODKEY,                    XKB_KEY_p,           spawn,            {.v = menucmd} },
            	{ MODKEY,                    XKB_KEY_Return,      spawn,            {.v = termcmd} },
            	{ MODKEY|WLR_MODIFIER_SHIFT, XKB_KEY_Return,      spawn,            {.v = termcmd} },
            	{ MODKEY,                    XKB_KEY_j,           focusstack,       {.i = +1} },
            	{ MODKEY,                    XKB_KEY_k,           focusstack,       {.i = -1} },
            	{ MODKEY,                    XKB_KEY_i,           incnmaster,       {.i = +1} },
            	{ MODKEY,                    XKB_KEY_d,           incnmaster,       {.i = -1} },
            	{ MODKEY,                    XKB_KEY_h,           setmfact,         {.f = -0.05f} },
            	{ MODKEY,                    XKB_KEY_l,           setmfact,         {.f = +0.05f} },
            	{ MODKEY,                    XKB_KEY_Return,      zoom,             {0} },
            	{ MODKEY,                    XKB_KEY_Tab,         view,             {0} },
            	{ MODKEY,                    XKB_KEY_c,           killclient,       {0} },
            	{ MODKEY,                    XKB_KEY_t,           setlayout,        {.v = &layouts[0]} },
            	{ MODKEY,                    XKB_KEY_f,           setlayout,        {.v = &layouts[1]} },
            	{ MODKEY,                    XKB_KEY_m,           setlayout,        {.v = &layouts[2]} },
            	{ MODKEY,                    XKB_KEY_space,       setlayout,        {0} },
            	{ MODKEY|WLR_MODIFIER_SHIFT, XKB_KEY_space,       togglefloating,   {0} },
            	{ MODKEY,                    XKB_KEY_e,           togglefullscreen, {0} },
            	{ MODKEY,                    XKB_KEY_0,           view,             {.ui = ~0} },
            	{ MODKEY|WLR_MODIFIER_SHIFT, XKB_KEY_parenright,  tag,              {.ui = ~0} },
            	{ MODKEY,                    XKB_KEY_comma,       focusmon,         {.i = WLR_DIRECTION_LEFT} },
            	{ MODKEY,                    XKB_KEY_period,      focusmon,         {.i = WLR_DIRECTION_RIGHT} },
            	{ MODKEY|WLR_MODIFIER_SHIFT, XKB_KEY_less,        tagmon,           {.i = WLR_DIRECTION_LEFT} },
            	{ MODKEY|WLR_MODIFIER_SHIFT, XKB_KEY_greater,     tagmon,           {.i = WLR_DIRECTION_RIGHT} },
            	{ MODKEY|WLR_MODIFIER_SHIFT, XKB_KEY_e,           quit,             {0} },
            	TAGKEYS(          XKB_KEY_1, XKB_KEY_exclam,                        0),
            	TAGKEYS(          XKB_KEY_2, XKB_KEY_at,                            1),
            	TAGKEYS(          XKB_KEY_3, XKB_KEY_numbersign,                    2),
            	TAGKEYS(          XKB_KEY_4, XKB_KEY_dollar,                        3),
            	TAGKEYS(          XKB_KEY_5, XKB_KEY_percent,                       4),
            	TAGKEYS(          XKB_KEY_6, XKB_KEY_asciicircum,                   5),
            	TAGKEYS(          XKB_KEY_7, XKB_KEY_ampersand,                     6),
            	TAGKEYS(          XKB_KEY_8, XKB_KEY_asterisk,                      7),
            	TAGKEYS(          XKB_KEY_9, XKB_KEY_parenleft,                     8),
            };

            static const Button buttons[] = {
            	{ MODKEY, BTN_LEFT,   moveresize,     {.ui = CurMove} },
            	{ MODKEY, BTN_MIDDLE, togglefloating, {0} },
            	{ MODKEY, BTN_RIGHT,  moveresize,     {.ui = CurResize} },
            };
          '';
        in
          (pkgs.dwl.override {inherit configH;});

        extraSessionCommands = ''
          # Mango exported these into the user session for portal/electron
          # apps; dwl's wrapper only imports DISPLAY/WAYLAND_DISPLAY.
          export XDG_CURRENT_DESKTOP=dwl
          export XDG_SESSION_DESKTOP=dwl
          export XDG_SESSION_TYPE=wayland
          export ELECTRON_OZONE_PLATFORM_HINT=auto
          export MOZ_ENABLE_WAYLAND=1
          export NIXOS_OZONE_WL=1
          ${pkgs.dbus}/bin/dbus-update-activation-environment --systemd \
            WAYLAND_DISPLAY DISPLAY \
            XDG_CURRENT_DESKTOP XDG_SESSION_DESKTOP XDG_SESSION_TYPE
        '';
      };

      # Session env vars for login shells/graphical apps started by dwl.
      environment.sessionVariables = {
        XDG_CURRENT_DESKTOP = "dwl";
        XDG_SESSION_DESKTOP = "dwl";
        XDG_SESSION_TYPE = "wayland";
      };

      # twm is provided for Xwayland-fallback workflows; it is NOT a session.
      # It is started by dwl-session wrapper on demand (see below).
    };

    homeManager = {pkgs, ...}: {
      home.packages = [
        pkgs.dmenu-wayland # dmenu-wl_run — SUPER+p launcher
        pkgs.tab-window-manager # X11 twm for Xephyr/Xnest workflows (user request)
        pkgs.wl-clipboard
        pkgs.wtype # keyboard event injection (Wayland ydotool-lite)
        pkgs.libnotify # notify-send
        pkgs.mako # notification daemon; dwl has no built-in notif surface
        pkgs.wlr-randr # display mode control for moonlight-only outputs
      ];
    };
  };
}
