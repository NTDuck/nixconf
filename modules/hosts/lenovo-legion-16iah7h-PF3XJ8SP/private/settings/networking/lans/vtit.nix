{den, ...}: {
  den.aspects.lenovo-legion-16iah7h-PF3XJ8SP = {
    nixos = {pkgs, ...}: let
      nic = "enp49s0";
      con = "ETH_VTIT_10.224.220.59";
      nmcli = "${pkgs.networkmanager}/bin/nmcli";
      iproute2 = "${pkgs.iproute2}/bin/ip";

      # eth-vtit: unified VTIT ethernet CLI (status / up / down / toggle).
      # Replaces former eth-vtit-up / eth-vtit-down shell aliases (2026-10-19).
      # Mirrors the ashalliant bin pattern: bare invocation shows status.
      #
      # Declarative NM profile attempt was abandoned ("doesn't work as
      # intended", never root-caused — see dell's vtit.nix for the same
      # decision); imperative nmcli kept knowingly. DELL carries a
      # verbatim twin of this CLI with only the NIC name differing
      # (enp0s31f6) — keep the two in sync.
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
  up)
    do_up
    ;;
  down)
    do_down
    ;;
  -h|--help|help)
    echo "usage: eth-vtit [status | toggle | up | down]"
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
    '1:command:((status\:"show status" toggle\:"toggle connection" up\:"bring connection up" down\:"tear connection down" list\:"show status"))' \
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
    COMPREPLY=( $(compgen -W "status toggle up down list -h --help" -- "$cur") )
  fi
}

complete -F _eth_vtit_completion eth-vtit
BASH

          cat << 'FISH' > $out/share/fish/vendor_completions.d/eth-vtit.fish
complete -c eth-vtit -n "__fish_use_subcommand" -a status -d "show status"
complete -c eth-vtit -n "__fish_use_subcommand" -a toggle -d "toggle connection"
complete -c eth-vtit -n "__fish_use_subcommand" -a up -d "bring connection up"
complete -c eth-vtit -n "__fish_use_subcommand" -a down -d "tear connection down"
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
