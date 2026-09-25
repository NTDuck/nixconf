# Shared omp TUI defaults for config.default.yml — SINGLE SOURCE OF
# TRUTH imported by the shared aspect (modules/features/dev/agentics/
# harnesses/oh-my-pi.nix) and generated for ALL hosts, dell included
# (2026-09-25 user request: dell back to symbolPreset = "nerd").
# modelRoles stay out — /model picks belong in the mutable config.yml
# (PI_CONFIG_FILES merges config.default.yml OVER it).
{
  symbolPreset = "nerd";

  composer = {
    shape = "box";
  };

  theme = {
    dark = "dark-rainforest";
    light = "light-forest";
  };

  setupVersion = 2;

  # Both hosts declare local servers under dot-free provider names
  # (legion-homelab: "bonsai2" + "ollama", see the hosts' private
  # aspects). omp's IMPLICIT "llama.cpp" discoverable would list the
  # same :8080 models twice — suppress the implicit one (2026-09-26).
  disabledProviders = ["llama.cpp"];

  astGrep = {
    enabled = true;
  };

  github = {
    enabled = true;
  };

  edit = {
    mode = "hashline";
  };

  memory = {
    backend = "mnemopi";
  };

  defaultThinkingLevel = "max";

  retry = {
    usageAwareFallback = false;
    fallbackRevertPolicy = "cooldown-expiry";
  };

  advisor = {
    enabled = true;
    syncBacklog = "off";
  };

  autolearn = {
    enabled = true;
    autoContinue = true;
  };

  followUpMode = "one-at-a-time";
  interruptMode = "immediate";

  tools = {
    approvalMode = "yolo";
  };

  error = {
    notify = "on";
  };

  update = {
    channel = "stable";
  };

  power = {
    sleepPrevention = "idle";
  };

  features = {
    unexpectedStopDetection = "smart";
  };

  colorBlindMode = false;

  statusLine = {
    preset = "default";
    separator = "powerline-thin";
    contextLine = "embedded";
    sessionAccent = false;
    transparent = false;
    compactThinkingLevel = true;
    showHookStatus = true;
  };

  terminal = {
    showProgress = true;
  };

  tui = {
    textSizing = true;
    codexResetFireworks = true;
    tight = false;
    hyperlinks = "always";
  };

  display = {
    shimmer = "classic";
    smoothStreaming = true;
    showTokenUsage = true;
    showTurnTime = true;
    cacheMissMarker = true;
  };

  task = {
    showResolvedModelBadge = true;
  };

  images = {
    blockImages = false;
  };

  modelRoleStorage = "global";
  personality = "default";

  prewalk = {
    enabled = false;
  };

  loop = {
    mode = "compact";
  };

  contextPromotion = {
    enabled = false;
  };
}
