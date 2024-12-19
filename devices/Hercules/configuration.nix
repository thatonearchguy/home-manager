# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, lib, pkgs, modulesPath, ... }:

let
    config_root = builtins.toString ./.;

in
{
  imports =
    [ # Include the results of the hardware scan.
      (config_root + "/./hardware-configuration.nix")
    ];

  nixpkgs.config.packageOverrides = pkgs: {
    nur = import (builtins.fetchTarball {
		    url = "https://github.com/nix-community/NUR/archive/master.tar.gz";
		    sha256 = "1wg0p6ahycza5jcw4ydcr0x4l6801y04rxaky8nqfmdsx0w93dr8";
    		})
    {
      inherit pkgs;
    };
  };


  #AMD iGPU
  boot.initrd.kernelModules= ["amdgpu"];

  boot.extraModulePackages = with pkgs; [ config.boot.kernelPackages.lenovo-legion-module
                               config.boot.kernelPackages.nvidia_x11
                             ];
  boot.kernelModules = ["nvidia" "legion-laptop" "i2c-dev" "ddcci_backlight"];

  hardware.graphics = {
    enable = true;
    extraPackages=with pkgs;[vaapiVdpau libvdpau-va-gl];
  };

  #NVIDIA GPU

  boot.kernelParams = [ "module_blacklist=nouveau" ];


  services.xserver.videoDrivers = [ "nvidia" ];
  hardware.nvidia = {

    modesetting.enable = true;
    powerManagement.enable = true;
    # Fine-grained power management. Turns off GPU when not in use.
    # Experimental and only works on modern Nvidia GPUs (Turing or newer).
    powerManagement.finegrained = true;
    dynamicBoost.enable = true;
    open = false;
    # Enable the Nvidia settings menu,
	# accessible via `nvidia-settings`.
    nvidiaSettings = true;
    package = config.boot.kernelPackages.nvidiaPackages.stable;
    prime = {
        amdgpuBusId = "PCI:6:0:0";
        nvidiaBusId = "PCI:1:0:0";
        offload = {
            enable = true;
            enableOffloadCmd = true;
        };
    };
    gsp.enable = false;
  };


  services.hardware.openrgb.enable = true;

  systemd.user.services.openrgb = {
      enable = true;
      description = "Open OpenRGB at boot";
      serviceConfig = {
          ExecStart = "${pkgs.openrgb}/bin/openrgb --startminimized";
          Restart = "on-failure";
          RestartSec = "5s";
      };
      wantedBy = [ "graphical-session.target" ];
  };

  systemd.user.services.legion_cli = {
      enable = true;
      description = "Set fancurve at boot";
      serviceConfig = {
          RemainAfterExit=true;
          Type="oneshot";
          ExecStart = "/etc/profiles/per-user/kavya/bin/bash ${pkgs.lenovo-legion}/bin/legion_cli fancurve-write-file-to-hw ${config_root}/fancurve.txt";
      };
      wantedBy = [ "graphical-session.target" ];
  };

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
  #  vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
    libva-utils
    libva
    amdgpu_top
    lenovo-legion
    prismlauncher
    mangohud
  ];
}
