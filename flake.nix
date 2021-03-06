{
  description = "quartz's system configs using Nix";

  inputs = {
    # nixpkgs
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    nixpkgs-master.url = "github:nixos/nixpkgs/master";
    # nixpkgs-master.url = "git+ssh://git@github.com/nixos/nixpkgs?ref=master";
    nixpkgs-stable-darwin.url = "github:nixos/nixpkgs/nixpkgs-20.09-darwin";
    nixos-stable.url = "github:nixos/nixpkgs/nixos-20.09";
    nur.url = "github:nix-community/NUR";


    # env
    darwin.url = "github:lnl7/nix-darwin";
    darwin.inputs.nixpkgs.follows = "nixpkgs";
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    # others
    comma = { url = "github:Shopify/comma"; flake = false; };
    utils.url = "github:numtide/flake-utils";
    malob.url = "github:malob/nixpkgs";
    # rnix-lsp.url = "github:nix-community/rnix-lsp";
    # rnix-lsp.inputs.nixpkgs.follows = "nixpkgs";
    # rnix-lsp.inputs.utils.follows = "utils";
  };


  outputs = { self, nur, darwin, home-manager, utils, ... }@inputs:
  let
    nixpkgs = inputs.nixpkgs-master;
    nixpkgsConfig = with inputs; {
      config.allowUnfree = true;
      config.allowUnsupportedSystem = true;
      overlays = self.overlays ++ [(final: prev:
      let
      	system = prev.stdenv.system;
      	nixpkgs-stable = if prev.stdenv.isDarwin then nixpkgs-stable-darwin else nixos-stable;
      in
      {
        stable = nixpkgs-stable.legacyPackages.${system};
        master = nixpkgs-master.legacyPackages.${system};
      })];
    };

    homeManagerConfig = with self.homeManagerModules; {
      imports = [
        ./home
      ];
    };

    mkNixDarwinModules = { user }: [
      inputs.malob.darwinModules.security.pam
      ./darwin
      home-manager.darwinModules.home-manager
      rec {
        nixpkgs = nixpkgsConfig;
        users.users.${user}.home = "/Users/${user}";
        home-manager.useGlobalPkgs = true;
        home-manager.useUserPackages = true;
        home-manager.users.${user} = homeManagerConfig;
        security.pam.enableSudoTouchIdAuth = true;
      }
    ];
  in {
    darwinConfigurations = {

      workMacPro = darwin.lib.darwinSystem {
        inputs = { inherit darwin nixpkgs; };
        modules = mkNixDarwinModules { user = "migmad"; } ++ [
          {
            networking.computerName = "vagabond 🥴";
            networking.hostName = "vagabond";
            networking.knownNetworkServices = [
              "Wi-Fi"
              "USB 10/100/1000 LAN"
            ];
          }
        ];
      };


      githubCI = darwin.lib.darwinSystem {
        modules = mkNixDarwinModules { user = "github-runner"; };
      };
    };

    darwinModules = {
    };

    homeManagerModules = { };

    overlays = with inputs; [
      (final: prev: {
        comma = import comma { inherit (prev) pkgs; };
        # rnix-lsp = import rnix-lsp { inherit (prev) pkgs; };
      })
      (import ./overlays)
    ];

    defaultPackage."x86_64-darwin" = self.darwinConfigurations.workMacPro.system;

  } // utils.lib.eachDefaultSystem (system: {
      legacyPackages = import nixpkgs { inherit system; inherit (nixpkgsConfig) config overlays; };
  });
}
