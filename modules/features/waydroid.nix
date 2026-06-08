{
  flake.modules.nixos.waydroid = {
    pkgs,
    config,
    lib,
    ...
  }: let
    username = config.this.username;
    hostname = config.this.hostname;
  in {
    virtualisation.waydroid.enable = true;

    environment.systemPackages = [
      pkgs.unstable.waydroid
    ];

    # This service runs automatically on system rebuilds and boots.
    # The `if` condition ensures it only executes the heavy lifting if Waydroid isn't set up.
    systemd.services.waydroid-auto-init = {
      description = "Auto-initialize Waydroid with GAPPS and libndk";
      wantedBy = ["multi-user.target"];
      after = ["network-online.target"];
      wants = ["network-online.target"];

      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
      };

      # Provide all the necessary dependencies directly to the script
      path = with pkgs; [
        waydroid
        python3
        git
        lzip
        squashfsTools
        coreutils
        bash
      ];

      script = ''
        IMAGE_DIR="/var/lib/waydroid/images"

        # Check if the system image exists
        if [ ! -f "$IMAGE_DIR/system.img" ]; then
          echo "Waydroid not initialized. Starting GAPPS initialization..."
          waydroid init -s GAPPS

          echo "GAPPS initialized. Preparing to inject libndk..."

          # Create a temporary workspace for the casualsnek script
          TMP_DIR=$(mktemp -d)
          cd "$TMP_DIR"

          # Clone the Waydroid script
          git clone https://github.com/casualsnek/waydroid_script.git
          cd waydroid_script

          # Setup an isolated Python virtual environment and install dependencies
          python3 -m venv venv
          source venv/bin/activate
          pip install -r requirements.txt

          # Run the injection script
          python3 main.py install libndk

          # Cleanup
          cd /
          rm -rf "$TMP_DIR"

          echo "Waydroid initialization and libndk injection complete."
        else
          echo "Waydroid is already initialized. Skipping script."
        fi
      '';
    };
  };
}
