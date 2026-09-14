{den, ...}: {
  den.aspects.virtualization.kubernetes = {
    nixos = {pkgs, ...}: {
      environment.systemPackages = [
        pkgs.unstable.minikube
        pkgs.unstable.kubectl
        pkgs.unstable.kubernetes-helm
        pkgs.unstable.kustomize
        pkgs.unstable.k9s
        pkgs.unstable.k3d
      ];
    };
  };
}
