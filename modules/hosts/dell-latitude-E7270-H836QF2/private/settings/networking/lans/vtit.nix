{den, ...}: {
  den.aspects.dell-latitude-E7270-H836QF2 = {
    nixos = {pkgs, ...}: let
      nic = "enp0s31f6";
      con = "ETH_VTIT_10.224.220.59";
      nmcli = "${pkgs.networkmanager}/bin/nmcli";
      iproute2 = "${pkgs.iproute2}/bin/ip";

      # eth-vtit: unified VTIT ethernet CLI (status / toggle).
      # Replaced former eth-vtit-up / eth-vtit-down shell aliases (2026-10-19);
      # explicit up/down subcommands dropped the same day — toggle covers the
      # control path, bare invocation shows status.
      # Mirrors the ninfer bin pattern: bare invocation shows status.
      #
      # DELL→legion hotspot connect: nmcli device wifi connect 'Hotto Doggo'
      #   password '20041889' (2.4GHz ch6 WPA2). DNS served by hotspot
      #   gateway 192.168.12.1 after the 2026-09-17 fix.
      # Mirror of Legion's eth-vtit CLI with the DELL static IP .59 (Legion owns .59).
      # The declarative networking.networkmanager.ensureProfiles variant was abandoned upstream
      # (see the commented block in the Legion file); imperative nmcli kept per that decision.
      eth-vtit = pkgs.stdenv.mkDerivation {
        pname = "eth-vtit";
        version = "1.0.0";

        dontUnpack = true;

        installPhase = ''
          runHook preInstall
          mkdir -p $out/bin $out/share/zsh/site-functions $out/share/bash-completion/completions $out/share/fish/vendor_completions.d

          cat << 'SCRIPT' > $out/bin/eth-vtit
#!/usr/bin/env bash
set -euo pipefail

NMCLI="${nmcli}"
IP="${iproute2}"
NIC="${nic}"
CON="${con}"

_nic_check() {
  "$IP" link show "$NIC" >/dev/null 2>&1 || {
    echo "eth-vtit: $NIC missing" >&2
    exit 1
  }
}

_profile_exists() {
  "$NMCLI" connection show id "$CON" >/dev/null 2>&1
}

_is_active() {
  [ "$("$NMCLI" -g GENERAL.STATE connection show id "$CON" 2>/dev/null)" = "activated" ]
}

show_status() {
  _nic_check
  local state="inactive"
  local addr="-"
  if _is_active; then
    state="active"
    addr=$("$NMCLI" -g IP4.ADDRESS connection show id "$CON" 2>/dev/null | head -1)
    [ -z "$addr" ] && addr="-"
  fi
  local carrier="no-carrier"
  if [ -r "/sys/class/net/$NIC/carrier" ] && [ "$(<"/sys/class/net/$NIC/carrier")" = "1" ] 2>/dev/null; then
    carrier="carrier"
  fi
  printf "%-26s %-12s %-10s %-12s %s\n" "$CON" "$NIC" "$state" "$carrier" "$addr"
}

do_up() {
  _nic_check
  if _profile_exists; then
    "$NMCLI" connection up "$CON" ifname "$NIC"
  else
    "$NMCLI" connection add \
      type ethernet \
      con-name "$CON" \
      ifname "$NIC" \
      autoconnect yes \
      connection.autoconnect-priority 100 \
      ip4 10.224.220.59/24 \
      gw4 10.224.220.1 \
      ipv4.dns "10.10.101.212 10.10.101.211" \
      ipv4.method manual \
      ipv6.method auto \
      proxy.method auto \
      proxy.pac-url "http://10.10.101.208/proxy.pac"
    "$NMCLI" connection up "$CON" ifname "$NIC"
  fi
}

do_down() {
  _nic_check
  if _profile_exists; then
    "$NMCLI" connection delete "$CON"
  else
    echo "eth-vtit: already down"
  fi
}

do_toggle() {
  if _is_active; then
    do_down
  else
    do_up
  fi
}

cmd="''${1:-}"
case "$cmd" in
  ""|list|status)
    show_status
    ;;
  toggle)
    do_toggle
    ;;
  -h|--help|help)
    echo "usage: eth-vtit [status | toggle]"
    ;;
  *)
    echo "unknown command '$cmd', run 'eth-vtit -h' for usage" >&2
    exit 1
    ;;
esac
SCRIPT
          chmod +x $out/bin/eth-vtit

          cat << 'ZSH' > $out/share/zsh/site-functions/_eth-vtit
#compdef eth-vtit

_eth-vtit() {
  _arguments -C \
    '1:command:((status\:"show status" toggle\:"toggle connection" list\:"show status"))' \
    '-h[show help]' \
    '--help[show help]'
}

_eth-vtit "$@"
ZSH

          cat << 'BASH' > $out/share/bash-completion/completions/eth-vtit
_eth_vtit_completion() {
  local cur
  cur="''${COMP_WORDS[COMP_CWORD]}"
  if [ "''${COMP_CWORD}" -eq 1 ]; then
    COMPREPLY=( $(compgen -W "status toggle list -h --help" -- "$cur") )
  fi
}

complete -F _eth_vtit_completion eth-vtit
BASH

          cat << 'FISH' > $out/share/fish/vendor_completions.d/eth-vtit.fish
complete -c eth-vtit -n "__fish_use_subcommand" -a status -d "show status"
complete -c eth-vtit -n "__fish_use_subcommand" -a toggle -d "toggle connection"
complete -c eth-vtit -n "__fish_use_subcommand" -a list -d "show status"
FISH

          runHook postInstall
        '';
      };
    in {
      environment.systemPackages = [eth-vtit];
    };
  };
}
