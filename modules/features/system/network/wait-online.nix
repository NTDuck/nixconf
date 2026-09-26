# Mask NetworkManager-wait-online: `nm-online` fails (exit 1) whenever any
# connection is still in the "connecting" state at the deadline — on legion
# the docker/podman bridges (`br-*`, `podman0`, `docker0`, `virbr0`) do not
# finish external activation before it (journal 2026-09-26: Main process
# exited, status=1/FAILURE), which failed the unit and delayed
# network-online.target (and podman-rp behind it) by a full timeout on
# every boot. Nothing on the host requires network-online ordering over NM
# readiness: long-poll daemons (tailscale, ollama consumers) retry on
# their own, and the bridges are runtime-only.
{
  den,
  ...
}: {
  den.aspects.system.network.wait-online = {
    nixos = {
      systemd.services."NetworkManager-wait-online".enable = false;
    };
  };
}
