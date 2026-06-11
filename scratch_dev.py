import os

files = {
    "alejandra.nix": """{
  den.aspects.alejandra = {
    nixos = {pkgs, ...}: {
      environment.systemPackages = [
        pkgs.unstable.alejandra
      ];
    };
  };
}
""",
    "cloudflare-warp.nix": """{
  den.aspects.cloudflare-warp = {
    nixos = {pkgs, ...}: {
      services.cloudflare-warp = {
        enable = true;
        package = pkgs.unstable.cloudflare-warp;

        openFirewall = true;
      };
    };
  };
}
""",
    "gh.nix": """{
  den.aspects.gh = {
    homeManager = {pkgs, ...}: {
      programs.gh = {
        enable = true;
        package = pkgs.unstable.gh;

        gitCredentialHelper.enable = true;
      };
    };
  };
}
""",
    "git.nix": """{
  den.aspects.git = {
    homeManager = {pkgs, ...}: {
      programs.git = {
        enable = true;
        package = pkgs.unstable.git;

        settings = {
          alias = {
            nccommit = "commit -a --allow-empty-message -m ''"; # https://trunk.io/blog/git-commit-messages-are-useless
          };
        };
      };
    };
  };
}
""",
    "glab.nix": """{
  den.aspects.glab = {
    nixos = {pkgs, ...}: {
      environment.systemPackages = [
        pkgs.unstable.glab
      ];
    };

    homeManager = {pkgs, ...}: {
      programs.git.settings = {
        credential."https://gitlab.com".helper = "!${pkgs.unstable.glab}/bin/glab auth git-credential";
      };
    };
  };
}
""",
    "speedtest-cli.nix": """{
  den.aspects.speedtest-cli = {
    nixos = {pkgs, ...}: {
      environment.systemPackages = [pkgs.unstable.speedtest-cli];
    };
  };
}
""",
    "agentics/agent-browser.nix": """{
  den.aspects.agent-browser = {
    nixos = {pkgs, ...}: {
      environment.systemPackages = [
        pkgs.unstable.agent-browser
      ];
    };
  };
}
""",
    "agentics/antigravity-cli.nix": """{
  den.aspects.antigravity-cli = {
    nixos = {
      pkgs,
      inputs,
      ...
    }: {
      environment.systemPackages = [
        inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system}.antigravity-cli
      ];

      # TODO Make YOLO default
    };
  };
}
""",
    "agentics/antigravity-usage.nix": """{
  den.aspects.antigravity-usage = {
    nixos = {pkgs, ...}: {
      # environment.systemPackages = [
      #   pkgs.unstable.nodejs
      #   pkgs.unstable.nodePackages.antigravity-usage
      # ];
    };

    homeManager = {pkgs, ...}: {
      # home.shellAliases = {
      #   agy-u = "${pkgs.unstable.nodePackages.antigravity-usage}/bin/antigravity-usage";
      # };
    };
  };
}
""",
    "agentics/claude-code.nix": """{
  den.aspects.claude-code = {
    homeManager = {pkgs, ...}: {
      programs.claude-code = {
        enable = true;
        package = pkgs.unstable.claude-code;
      };
    };
  };
}
""",
    "agentics/codex.nix": """{
  den.aspects.codex = {
    homeManager = {pkgs, ...}: {
      programs.codex = {
        enable = true;
        package = pkgs.unstable.codex;
      };
    };
  };
}
""",
    "agentics/ollama.nix": """{
  den.aspects.ollama = {
    nixos = {
      lib,
      pkgs,
      ...
    }: {
      services.ollama = {
        enable = true;
        package = pkgs.unstable.ollama;

        syncModels = true;
        loadModels = [
          "gemma4:e2b"
          "gemma4:e4b"
          "mxbai-embed-large"
        ];
      };

      systemd.services.ollama.wantedBy = lib.mkForce []; # Prevents autostart
    };
  };
}
""",
    "agentics/qoder-cli.nix": """{
  den.aspects.qoder-cli = {
    nixos = {
      pkgs,
      inputs,
      ...
    }: {
      environment.systemPackages = [
        inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system}.qoder-cli
      ];
    };
  };
}
""",
    "toolchains/c-cpp.nix": """{
  den.aspects.dev-toolchains = {
    nixos = {pkgs, ...}: {
      environment.systemPackages = [
        pkgs.unstable.clang-tools
        pkgs.unstable.xmake
        pkgs.unstable.cmake-language-server
        pkgs.unstable.nim
      ];
    };
  };
}
""",
    "toolchains/docker.nix": """{}
""",
    "toolchains/java-kotlin.nix": """{
  den.aspects.dev-toolchains = {
    nixos = {pkgs, ...}: {
      environment.systemPackages = [
        pkgs.unstable.jdk21

        pkgs.unstable.maven
        pkgs.unstable.gradle

        pkgs.unstable.spring-boot-cli
        pkgs.unstable.jdt-language-server

        pkgs.unstable.jetbrains.idea-oss
      ];

      environment.sessionVariables = {
        JAVA_HOME = "${pkgs.unstable.jdk21.home}";
      };
    };
  };
}
""",
    "toolchains/javascript-typescript.nix": """{
  den.aspects.dev-toolchains = {
    nixos = {pkgs, ...}: {
      environment.systemPackages = [
        pkgs.unstable.deno

        pkgs.unstable.javascript-typescript-langserver
        pkgs.unstable.tailwindcss-language-server

        pkgs.unstable.svelte-language-server
      ];
    };

    homeManager = {pkgs, ...}: {
      programs.bun = {
        enable = true;
        package = pkgs.unstable.bun;

        settings = {
          telemetry = false;
        };
      };
    };
  };
}
""",
    "toolchains/lua.nix": """{
  den.aspects.dev-toolchains = {
    nixos = {pkgs, ...}: {
      environment.systemPackages = [
        pkgs.unstable.lua-language-server
      ];
    };
  };
}
""",
    "toolchains/nix.nix": """{
  den.aspects.dev-toolchains = {
    nixos = {pkgs, ...}: {
      environment.systemPackages = [
        pkgs.unstable.nil
        pkgs.unstable.nixd
      ];
    };
  };
}
""",
    "toolchains/protobuf.nix": """{
  den.aspects.dev-toolchains = {
    nixos = {pkgs, ...}: {
      environment.systemPackages = [
        pkgs.unstable.protobuf
        pkgs.unstable.protobuf-language-server
      ];
    };
  };
}
""",
    "toolchains/python.nix": """{
  den.aspects.dev-toolchains = {
    nixos = {pkgs, ...}: {
      environment.systemPackages = [
        pkgs.unstable.python3
        pkgs.unstable.python3Packages.pip
        pkgs.unstable.python3Packages.virtualenv
      ];
    };

    homeManager = {pkgs, ...}: {
      programs.poetry = {
        enable = true;
        package = pkgs.unstable.poetry;
      };

      programs.uv = {
        enable = true;
        package = pkgs.unstable.uv;
      };
    };
  };
}
""",
    "toolchains/rust.nix": """{
  den.aspects.dev-toolchains = {
    nixos = {pkgs, ...}: {
      environment.systemPackages = [
        (pkgs.rust-bin.stable.latest.default.override {
          extensions = ["rust-src" "rust-analyzer"];
        })

        pkgs.unstable.cargo-nextest
        pkgs.unstable.cargo-binstall

        pkgs.unstable.gcc
        pkgs.unstable.pkg-config
        pkgs.unstable.openssl

        pkgs.unstable.taplo # .toml
      ];
    };
  };
}
""",
    "toolchains/topiary.nix": """{
  den.aspects.dev-toolchains = {
    nixos = {pkgs, ...}: {
      environment.systemPackages = [
        pkgs.unstable.topiary

        pkgs.unstable.nickel # .ncl
        pkgs.unstable.ts_query_ls # .scm
      ];
    };
  };
}
"""
}

base_dir = "/home/ayin/projs/nixconf/den/v1/modules/features/dev"
for rel_path, content in files.items():
    full_path = os.path.join(base_dir, rel_path)
    os.makedirs(os.path.dirname(full_path), exist_ok=True)
    with open(full_path, "w") as f:
        f.write(content)
