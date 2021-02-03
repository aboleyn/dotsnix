{ config, pkgs, ... }:

{
  programs.home-manager.enable = true;

  imports = [
    ./modules/programs/fish.nix
    ./modules/programs/kakoune.nix
  ];

  home.packages = with pkgs; [
    # nix
    cachix
    nixpkgs-fmt
    rnix-lsp

    # terminal/shell goodies
    ranger
    tig
    lazygit
    thefuck
    ripgrep # grep replacement (in rust)
    exa # ls replacement (in rust)
    fd # find replacement (in rust)
    jq
    fzy
    skim
    cowsay
    tree

    # compilers/vms/runtimes
    python2Full
    python39
    nodejs_latest
    zig-master

    # others
    ffmpeg
    sqlite
    bitwarden-cli

    # os goodies
    folderify
  ];

  home.sessionVariables = {
    EDITOR = "vim";
    # PAGER = "col -b -x | kak";
    # MANPAGER = "col -b -x | kak -e 'set buffer filetype man'";
  };


  programs.bash.enable = true;
  programs.zsh.enable = true;

  programs.direnv.enable = true;
  programs.direnv.enableNixDirenvIntegration = true;

  programs.starship = {
    enable = true;
    enableBashIntegration = true;
    enableZshIntegration = true;
    enableFishIntegration = true;

    settings = {
    };
  };

  programs.bat.enable = true;

  programs.neovim = {
    enable = true;
    vimAlias = true;
    extraConfig = ''
    colorscheme gruvbox
    set number
    set relativenumber
    '';
    plugins = with pkgs.vimPlugins; [
      vim-nix
      gruvbox
    ];
  };

  programs.tmux = {
    enable = true;
    clock24 = true;
    keyMode = "vi"; 
    historyLimit = 20000;
    extraConfig = ''
    set -g mouse on 
    '';
  };
}
