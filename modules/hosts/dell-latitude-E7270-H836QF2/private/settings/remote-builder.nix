# Distributed Nix builds on Dell (2026-11-08): same HP ProBook worker
# as legion (see legion's private/settings/remote-builder.nix for the
# design notes). Declarative and inert while dell is offline; applies
# on its next rebuild. Prerequisite before first use: dell's ayin
# pubkey must be added to HP's ayin authorizedKeys (HP's
# remote-builder.nix pins legion's only) — nix-daemon reads the key as
# root, but the path is ayin's.
{
  ...
}: {
  den.aspects.dell-latitude-E7270-H836QF2 = {
    nixos = {
      programs.ssh.knownHosts.hp-probook = {
        hostNames = [
          "hp-probook-450-g3-5cd8132yc3"
          "hp-probook-450-g3-5CD8132YC3"
          "100.89.126.41"
        ];
        publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJudd3RiHjp1wyTxJpEBKYCdJJfMPRBM4i3tERv+XqNM";
      };

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
