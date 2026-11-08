# Distributed Nix builds on legion (2026-11-08): offload to the HP
# ProBook headless worker over Tailscale. HP's ayin is trusted there
# (trusted-users = @wheel) and its authorized key is pinned in HP's
# private/settings/remote-builder.nix. Pin HP's host key here so
# root's ssh (nix-daemon) verifies it non-interactively — no tty to
# accept a prompt.
{
  ...
}: {
  den.aspects.lenovo-legion-16iah7h-PF3XJ8SP = {
    nixos = {
      programs.ssh.knownHosts.hp-probook = {
        hostNames = [
          "hp-probook-450-g3-5cd8132yc3"
          "hp-probook-450-g3-5CD8132YC3"
          "100.89.126.41"
        ];
        publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJudd3RiHjp1wyTxJpEBKYCdJJfMPRBM4i3tERv+XqNM";
      };

      # An unreachable HP falls back to local builds by default
      # (buildMachines never blocks; no `mandatory` option exists in
      # nixpkgs' schema). No supportedFeatures: HP (4c i5-6200U,
      # 7.7 GiB) must NOT claim big-parallel/kvm/nixos-test — jobs
      # needing those stay on legion. speedFactor defaults to 1, so
      # legion (implicit, faster) is preferred first.
      nix.distributedBuilds = true;
      nix.buildMachines = [
        {
          hostName = "hp-probook-450-g3-5cd8132yc3";
          sshUser = "ayin";
          sshKey = "/home/ayin/.ssh/id_ed25519";
          systems = ["x86_64-linux"];
          maxJobs = 4;
        }
      ];
    };
  };
}
