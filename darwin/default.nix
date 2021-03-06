{ lib, config, pkgs, ... }:

{
  imports = [
    # ./bootstrap.nix
    ./macos.nix
    #./yabai.nix
  ] ++ lib.filter lib.pathExists [ ./private.nix ];

  nixpkgs.overlays = [
    (self: super: {
      lazygit = super.callPackage ./pkgs/lazygit.nix { };
      zig-master = super.callPackage ./pkgs/zig-master.nix { };
      ssm = super.callPackage ./pkgs/ssm.nix { };
      yabai = super.yabai.overrideAttrs (o: rec {
        version = "3.3.6";
        src = builtins.fetchTarball {
          url = "https://github.com/koekeishiya/yabai/releases/download/v${version}/yabai-v${version}.tar.gz";
          sha256 = "0a4yb1wisxhn7k8f9l4bp8swkb17qdkc4crh42zvz4lpaxg0sgxi";
        };
      });
    })
  ];

  environment.systemPackages = with pkgs; [
    exa
    curl
    wget
    htop
    git
    vim
    ssm
    #yabai
    #skhd
    comma
  ];

  users.users.migmad = {
    home = "/Users/migmad";
    description = "Miguel Madureira";
    shell = pkgs.fish;
    packages = with pkgs; [
      home-manager
    ];
  };

  environment.variables = {
    PAGER = "less -R";
    EDITOR = "vim";
  };

  environment.shellAliases = {
    ls = "exa";
  };

  programs.nix-index.enable = true;

  # services.lorri.enable = true;

  programs.bash.enable = true;
  programs.zsh.enable = true;
  programs.fish = {
    enable = true;
    useBabelfish = true;
    babelfishPackage = pkgs.master.babelfish;
    # Needed to address bug where $PATH is not properly set for fish:
    # https://github.com/LnL7/nix-darwin/issues/122
    interactiveShellInit = ''
      for p in (string split : ${config.environment.systemPath})
        if not contains $p $fish_user_paths
          set -g fish_user_paths $fish_user_paths $p
        end
      end
    '';
  };
  # Needed to ensure Fish is set as the default shell:
  # https://github.com/LnL7/nix-darwin/issues/146
  environment.variables.SHELL = "${pkgs.fish}/bin/fish";
  environment.shells = with pkgs; [ fish zsh bash ];


  services.activate-system.enable = true;

  # Used for backwards compatibility, please read the changelog before changing.
  # $ darwin-rebuild changelog
  system.stateVersion = 4;

  # Auto upgrade nix package and the daemon service.
  services.nix-daemon.enable = true;
  # Enable experimental version of nix with flakes support
  nix.package = pkgs.nixFlakes;
  nix.extraOptions = ''
    experimental-features = nix-command flakes
    keep-outputs = true
    keep-derivations = true
  '';
  # You should generally set this to the total number of logical cores in your system.
  # $ sysctl -n hw.ncpu
  nix.maxJobs = 12;
  nix.buildCores = 0;
}

