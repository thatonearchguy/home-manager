# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, modulesPath, ... }:

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
		    sha256 = "0dlddsa3vhfzgbzrdj4hdfdmcw91p6hamcb6fagx3xa1h66kf23g";
    		})
    {
      inherit pkgs;
    };
  };


  #AMD iGPU

  hardware.opengl.extraPackages=with pkgs;[vaapiVdpau libvdpau-va-gl];
  boot.initrd.kernelModules= ["amdgpu"];

  boot.extraModulePackages = with pkgs; [ linuxKernel.packages.linux_zen.lenovo-legion-module
                               linuxKernel.packages.linux_zen.nvidia_x11
                             ];
  boot.kernelModules = ["nvidia" "legion-laptop"];


  #NVIDIA GPU
  hardware.opengl = {
    enable = true;
  };

  boot.kernelParams = [ "module_blacklist=nouveau" ];
  services.xserver.videoDrivers = [ "nvidia" ];
  hardware.nvidia = {

    modesetting.enable = true;
    powerManagement.enable = true;
    # Fine-grained power management. Turns off GPU when not in use.
    # Experimental and only works on modern Nvidia GPUs (Turing or newer).
    powerManagement.finegrained = true;
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

  systemd.user.services.legion_gui = {
      enable = true;
      description = "Set fancurve at boot";
      serviceConfig = {
          ExecStart = "${pkgs.lenovo-legion}/bin/legion_cli fancurve-write-file-to-hw ${config_root}/fancurve.txt";
          Restart = "on-failure";
          RestartSec = "5s";
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
  ];
}
