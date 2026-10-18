# Shared omp Gemini modelOverrides — caps Gemini context windows from default
# 1M (1,048,576 tokens) down to 256k (256,000 tokens) across both hosts.
# 256000 matches omp's decimal formatTokens rounding (displays as "256K" in
# `omp models`) and prevents extreme latency and memory bloat on deep turns.
let
  cap = {contextWindow = 256000;};
  mkOverrides = models:
    builtins.listToAttrs (map (id: {
      name = id;
      value = cap;
    }) models);
in {
  google.modelOverrides = mkOverrides [
    "gemini-1.5-flash"
    "gemini-1.5-flash-8b"
    "gemini-1.5-pro"
    "gemini-2.0-flash"
    "gemini-2.0-flash-lite"
    "gemini-2.5-flash"
    "gemini-2.5-flash-lite"
    "gemini-2.5-pro"
    "gemini-3-flash-preview"
    "gemini-3-pro-preview"
    "gemini-3.1-flash-lite"
    "gemini-3.1-pro-preview"
    "gemini-3.5-flash"
    "gemini-3.5-flash-lite"
    "gemini-3.6-flash"
    "gemini-3.7-flash"
    "gemini-3.8-flash"
    "gemini-4-argon"
    "gemini-flash-latest"
    "gemini-flash-lite-latest"
    "gemini-pro-latest"
  ];

  google-antigravity.modelOverrides = mkOverrides [
    "gemini-2.5-flash"
    "gemini-2.5-flash-lite"
    "gemini-3-flash"
    "gemini-3.1-flash-lite"
    "gemini-3.5-flash"
    "gemini-3.5-flash-lite"
    "gemini-3.8-flash"
    "gemini-4-argon-disabled"
  ];

  opencode-zen.modelOverrides = mkOverrides [
    "gemini-3-flash"
    "gemini-3-pro"
    "gemini-3.1-pro"
    "gemini-3.5-flash"
    "gemini-3.5-flash-lite"
    "gemini-3.6-flash"
    "gemini-3.7-flash"
    "gemini-3.8-flash"
    "gemini-4-argon"
  ];

  opencode-go.modelOverrides = mkOverrides [
    "gemini-4-argon-contributor"
  ];

  openrouter.modelOverrides = mkOverrides [
    "~google/gemini-flash-latest"
    "~google/gemini-pro-latest"
    "google/gemini-2.0-flash-001"
    "google/gemini-2.0-flash-lite-001"
    "google/gemini-2.5-flash"
    "google/gemini-2.5-flash-lite"
    "google/gemini-2.5-flash-lite-preview-09-2025"
    "google/gemini-2.5-flash-lite:batch"
    "google/gemini-2.5-flash-preview-09-2025"
    "google/gemini-2.5-flash:batch"
    "google/gemini-2.5-pro"
    "google/gemini-2.5-pro-preview"
    "google/gemini-2.5-pro-preview-05-06"
    "google/gemini-2.5-pro:batch"
    "google/gemini-3-flash-preview"
    "google/gemini-3-flash-preview:batch"
    "google/gemini-3-pro-preview"
    "google/gemini-3.1-flash-lite"
    "google/gemini-3.1-flash-lite-preview"
    "google/gemini-3.1-flash-lite:batch"
    "google/gemini-3.1-pro-preview"
    "google/gemini-3.1-pro-preview-customtools"
    "google/gemini-3.1-pro-preview:batch"
    "google/gemini-3.5-flash"
    "google/gemini-3.5-flash-lite"
    "google/gemini-3.5-flash-lite:batch"
    "google/gemini-3.5-flash:batch"
    "google/gemini-3.6-flash"
    "google/gemini-3.6-flash:batch"
    "google/gemini-3.7-flash"
    "google/gemini-3.7-flash:batch"
    "google/gemini-3.8-flash"
    "google/gemini-3.8-flash:batch"
    "google/gemini-4-argon"
    "google/gemini-4-argon:batch"
  ];
}
