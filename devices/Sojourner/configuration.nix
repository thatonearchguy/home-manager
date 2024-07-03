# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
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

  boot.kernelParams = [
    "video=LVDS-1:1366x768@75"
  ];

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
  #  vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
    intel-vaapi-driver
    inteltool
  ];
}
