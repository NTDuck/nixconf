{...}: {
  imports = [
    ./gemini.nix
    ./llm-agents.nix
    ./ollama.nix
    # install paperclip too!
  ];
}
