# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).
{ config, pkgs, ... }:


let
    targetDevice = "Sojourner";
in
{
    {
    imports =
        [ # Include the results of the hardware scan.
        
            "./$targetDevice/configuration.nix"
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

    # Bootloader.
    boot.loader.systemd-boot.enable = true;
    boot.loader.efi.canTouchEfiVariables = true;

    networking.hostName = "$targetDevice"; # Define your hostname.
    # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

    # Configure network proxy if necessary
    # networking.proxy.default = "http://user:password@proxy:port/";
    # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

    # Enable networking
    networking.networkmanager.enable = true;

    # Set your time zone.
    time.timeZone = "Europe/London";

    # Select internationalisation properties.
    i18n.defaultLocale = "en_GB.UTF-8";

    i18n.extraLocaleSettings = {
        LC_ADDRESS = "en_GB.UTF-8";
        LC_IDENTIFICATION = "en_GB.UTF-8";
        LC_MEASUREMENT = "en_GB.UTF-8";
        LC_MONETARY = "en_GB.UTF-8";
        LC_NAME = "en_GB.UTF-8";
        LC_NUMERIC = "en_GB.UTF-8";
        LC_PAPER = "en_GB.UTF-8";
        LC_TELEPHONE = "en_GB.UTF-8";
        LC_TIME = "en_GB.UTF-8";
    };

    boot.kernelPackages = pkgs.linuxPackages_zen;
    boot.kernelParams = [
        "zswap.enabled=1"
        "pcie_acs_override=downstream,multifunction"
        "amd_pstate=active"
        "mitigations=off"
        "panic=1"
        "nowatchdog"
        "nmi_watchdog=0"
        "quiet"
        "rd.systemd.show_status=auto"
        "rd.udev.log_priority=3"
    ];

    boot.kernel.sysctl = {
        "vm.swappiness" = 15;
        "vm.vfs_cache_pressure" = 50;
    };

    # Enable the X11 windowing system.
    # You can disable this if you're only using the Wayland session.
    services.xserver.enable = true;

    # Enable the KDE Plasma Desktop Environment.
    services.displayManager.sddm.enable = true;
    services.desktopManager.plasma6.enable = true;
    
    services.psd.enable = true;

    systemd.user.services.yakuake = {
        enable = true;
        description = "Open Yakuake at boot";
        serviceConfig = {
        ExecStart = "${pkgs.yakuake}/bin/yakuake";
        wantedBy = [ "graphical-session.target" ];
        Restart = "on-failure";
        RestartSec = "5s";
        };
    };

    # Configure keymap in X11
    services.xserver = {
        layout = "gb";
        xkbVariant = "";
    };

    # Configure console keymap
    console.keyMap = "uk";

    # Enable CUPS to print documents.
    services.printing.enable = true;

    security.sudo.extraConfig = ''
        Defaults        timestamp_timeout=30
        kavya ALL=(ALL) NOPASSWD: /nix/store/ab9zmvn353kxdci7kn9g7n5vw51yriy4-profile-sync-daemon-6.50/bin/psd-overlay-helper
    '';

    # Enable sound with pipewire.
    hardware.pulseaudio.enable = false;
    security.rtkit.enable = true;
    services.pipewire = {
        enable = true;
        alsa.enable = true;
        alsa.support32Bit = true;
        pulse.enable = true;
        # If you want to use JACK applications, uncomment this
        #jack.enable = true;

        # use the example session manager (no others are packaged yet so this is enabled by default,
        # no need to redefine it in your config for now)
        #media-session.enable = true;
    };

    # Enable touchpad support (enabled default in most desktopManager).
    # services.xserver.libinput.enable = true;

    # Define a user account. Don't forget to set a password with ‘passwd’.
    users.users.kavya = {
        isNormalUser = true;
        description = "KD";
        extraGroups = [ "networkmanager" "wheel" ];
        packages = with pkgs; [
        kdePackages.kate
        #  thunderbird
        ];
    };

    # Install firefox.
    programs.firefox.enable = true;

    # Allow unfree packages
    nixpkgs.config.allowUnfree = true;
    nixpkgs.config.segger-jlink.acceptLicense = true;
    nix.settings.experimental-features = [ "nix-command" "flakes" ];
    # List packages installed in system profile. To search, run:
    # $ nix search wget
    environment.systemPackages = with pkgs; [
    #  vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
        kdePackages.yakuake
        vscode
        vesktop
        kdePackages.filelight
        heroic
        kicad
        bluez
        brave
        picoscope
        libreoffice-qt6-still
        nrf-command-line-tools
        nrfconnect
        catppuccin-kde
        catppuccin-sddm
        catppuccin-gtk
        catppuccin-kvantum
        catppuccin-cursors
        catppuccin-plymouth
        catppuccin-papirus-folders
        vscode-extensions.catppuccin.catppuccin-vsc
        vscode-extensions.catppuccin.catppuccin-vsc-icons
        tela-circle-icon-theme
        powertop
        linuxKernel.packages.linux_latest_libre.cpupower
        zsh
        zsh-completions
        zsh-powerlevel9k
        zsh-autocomplete
        htop
        vlc
        qbittorrent
        rustup
        rustc
        git
        libgcc
        gcc
        wget
        curl
        roon-tui
        kdePackages.qtstyleplugin-kvantum
        distrobox
        profile-sync-daemon
        glib

    ];

    nixpkgs.config.permittedInsecurePackages = [
                    "segger-jlink-qt4-794l"
    ];

    fonts.packages = with pkgs; [
        fira-code-symbols
        fira-code
        redhat-official-fonts
    ];

    # Some programs need SUID wrappers, can be configured further or are
    # started in user sessions.
    # programs.mtr.enable = true;
    # programs.gnupg.agent = {
    #   enable = true;
    #   enableSSHSupport = true;
    # };

    # List services that you want to enable:

    # Enable the OpenSSH daemon.
    # services.openssh.enable = true;

    # Open ports in the firewall.
    # networking.firewall.allowedTCPPorts = [ ... ];
    # networking.firewall.allowedUDPPorts = [ ... ];
    # Or disable the firewall altogether.
    # networking.firewall.enable = false;

    # This value determines the NixOS release from which the default
    # settings for stateful data, like file locations and database versions
    # on your system were taken. It‘s perfectly fine and recommended to leave
    # this value at the release version of the first install of this system.
    # Before changing this value read the documentation for this option
    # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
    system.stateVersion = "24.05"; # Did you read the comment?

    }
}