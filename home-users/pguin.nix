{ pkgs, config, lib, inputs, ... }:

{
  imports = [
    inputs.nix-colors.homeManagerModules.default
  ];

  colorScheme = inputs.nix-colors.colorSchemes.gruvbox-dark-medium;

  home.username = "pguin";
  home.homeDirectory = "/home/pguin";
  home.stateVersion = "25.05";

  # --- PACKAGES ---
  home.packages = with pkgs; [
    # Dev Toolchains
    python313
    zsh-autocomplete

    # Editors & LSPs
    helix
    marksman
    ruff
    python313Packages.python-lsp-server
    dprint
    taplo

    # CLI Tools & Utilities
    tmux
    keychain
    git
    gh
    yazi
    ueberzugpp
    unar
    ffmpegthumbnailer
    poppler_utils
    w3m
    zathura
    tree
    wget
    ffmpeg

    # For hyprland
    waybar
    eww
    dunst
    libnotify
    swww
    kitty
    rofi-wayland
    kdePackages.dolphin
    networkmanagerapplet
    grim # screenshot utility
    slurp # selection utility
    wl-clipboard # clipboard

    # Programs
    # code
    obs-studio
    telegram-desktop
    mpv
    discord
    krita
  ];

  # --- ZSH CONFIGURATION ---
  programs.zsh = {
    enable = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;
    # keyMap = "vi"; # Using bindkey -v in initContent for reliability

    shellAliases = {
      ls = "ls --color=auto -F";
      ll = "ls -alhF";
      la = "ls -AF";
      l  = "ls -CF";
      glog = "git log --oneline --graph --decorate --all";
      cc = "clang";
      cxx = "clang++";
    };

    history = {
      size = 10000;
      path = "${config.xdg.dataHome}/zsh/history";
      share = true;
      ignoreDups = true;
      ignoreSpace = true;
      save = 10000;
    };

    initContent = ''
      # Enable Vi Keybindings
      bindkey -v

      # --- PATH Exports ---
      export PATH="$HOME/.cargo/bin:$PATH"
      export PATH="$HOME/.local/bin:$PATH"
      export PATH="$HOME/.npm-global/bin:$PATH"

      export KEYTIMEOUT=150 # For Vi mode ESC responsiveness

      # History search keybindings - COMMENTED OUT to allow zsh-autocomplete to use arrow keys
      # autoload -Uz up-line-or-beginning-search down-line-or-beginning-search
      # zle -N up-line-or-beginning-search
      # zle -N down-line-or-beginning-search
      # bindkey "^[[A" up-line-or-beginning-search
      # bindkey "^[[B" down-line-or-beginning-search

      # --- Custom Functions ---
      multipull() {
        local BASE_DIR=~/.code
        if [[ ! -d "$BASE_DIR" ]]; then
          echo "multipull: Base directory not found: $BASE_DIR" >&2
          return 1
        fi
        echo "Searching for Git repositories under $BASE_DIR..."
        fd --hidden --no-ignore --type d '^\.git$' "$BASE_DIR" | while read -r gitdir; do
          local workdir=$(dirname "$gitdir")
          echo -e "\n=== Updating $workdir ==="
          if (cd "$workdir" && git rev-parse --abbrev-ref --symbolic-full-name '@{u}' &>/dev/null); then
            git -C "$workdir" pull
          else
            local branch=$(git -C "$workdir" rev-parse --abbrev-ref HEAD)
            echo "--- Skipping pull (no upstream configured for branch: $branch) ---"
          fi
        done
        echo -e "\nMultipull finished."
      }

      _activate_venv() {
        local venv_name="$1"
        local venv_activate_path="$2"
        if [[ ! -f "$venv_activate_path" ]]; then
          echo "Error: Activation script not found: $venv_activate_path" >&2; return 1
        fi
        # Deactivate if another venv is active.
        # Uses Zsh-compatible check for whether 'deactivate' command (function) exists.
        # Bash's `type -t deactivate` is not portable to Zsh.
        if (( $+commands[deactivate] )); then
          deactivate
        fi
        . "$venv_activate_path" && echo "Activated venv: $venv_name"
      }

      # Virtual environment activation functions
      # Assuming venvs are created in ~/.venv/python3.13/<env_name>
      v_mlmenv() {
        _activate_venv "mlmenv (Python 3.13)" "$HOME/.venv/python3.13/mlmenv/bin/activate"
      }
      v_crawl4ai() {
        _activate_venv "crawl4ai (Python 3.13)" "$HOME/.venv/python3.13/crawl4ai/bin/activate"
      }
    '';
  };

  # --- PROGRAM CONFIGURATIONS ---
  programs.starship.enable = true;

  programs.firefox = {
    enable = true;
  };
   
  programs.helix.enable = true;

  programs.fzf = {
    enable = true;
    enableZshIntegration = true;
    defaultCommand = "fd --type f --hidden --follow --exclude .git";
    defaultOptions = [
      "--height 40%"
      "--layout=reverse"
      "--border"
      "--prompt='➜  '"
    ];
  };

  programs.git = {
    enable = true;
    userEmail = "138515193+pguin-sudo@users.noreply.github.com";
    userName = "PGuin";
  };

  programs.vscode = {
    enable = true;
    extensions = with pkgs.vscode-extensions; [];
  };

  # --- MANAGING CONFIGURATION FILES ---

  home.file."${config.xdg.configHome}" = {
    source = ../dotfiles;
    recursive = true;
  };

  # --- GLOBAL ENVIRONMENT VARIABLES ---
  home.sessionVariables = {
    EDITOR = "hx";
    VISUAL = "hx";
    PAGER = "less";
    CC = "clang";
    CXX = "clang++";
    GIT_TERMINAL_PROMPT = "1";
    FZF_ALT_C_COMMAND = "fd --type d --hidden --follow --exclude .git";
  };   
}
