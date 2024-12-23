# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).
{ config, lib, pkgs, modulesPath, targetDevice, ... }:


let
    core_root = builtins.toString ./.;

    targetDevice = "Hercules";
    appmenu-gtk3-module = (pkgs.callPackage ./appmenu.nix {});
in
{
    imports =
        [ # Include the specified device's configuration.
        
            (core_root + "/${targetDevice}/configuration.nix")
        ];

    nixpkgs.config.packageOverrides = pkgs: {
        nur = import (builtins.fetchTarball "https://github.com/nix-community/NUR/archive/master.tar.gz") {
            inherit pkgs;
        };
    };

    # Bootloader.
    boot.loader.grub.enable = true;
    boot.loader.grub.device = "nodev";
    boot.loader.grub.useOSProber = true;
    boot.loader.grub.efiSupport = true;

    boot.loader.grub.theme = pkgs.stdenv.mkDerivation {
        pname = "catppuccin-grub";
        version = "3.1";
        src = pkgs.fetchFromGitHub {
            owner = "catppuccin";
            repo = "grub";
            rev = "88f6124757331fd3a37c8a69473021389b7663ad";
            sha256 = "0rih0ra7jw48zpxrqwwrw1v0xay7h9727445wfbnrz6xwrcwbibv";
        };
        installPhase = "cp -r src/catppuccin-frappe-grub-theme $out";
    };

    boot.loader.efi.canTouchEfiVariables = true;
    boot.plymouth.enable = true;
    boot.plymouth.theme = "catppuccin-macchiato";
    boot.plymouth.themePackages = with pkgs; [ catppuccin-plymouth ];

    networking.hostName = "${targetDevice}"; # Define your hostname.
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


    services.pipewire.wireplumber.extraConfig = {
        "monitor.bluez.properties" = {
            "bluez5.enable-sbc-xq" = true;
            "bluez5.enable-msbc" = true;
            "bluez5.enable-hw-volume" = true;
            "bluez5.roles" = [ "hsp_hs" "hsp_ag" "hfp_hf" "hfp_ag" ];
        };
    };

    hardware.pulseaudio.enable = false;
    hardware.bluetooth = {
        enable = true;
        powerOnBoot = true;
        settings = {
        General = {
            Enable = "Source,Sink,Media,Socket";
            Experimental = true;
        };
        };
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
          ExecStartPre = "${pkgs.coreutils}/bin/sleep 10";
          Restart = "on-failure";
          RestartSec = "5s";
      };
      wantedBy = [ "plasma-workspace.target" ];
    };


    systemd.user.services.poweroptimise = {
      enable = true;
      description = "Apply power optimisations at boot";
      serviceConfig = {
          ExecStart = "${pkgs.bash}/bin/bash ${core_root}/${targetDevice}/powertop-tune.sh";
          Restart = "on-failure";
          RestartSec = "5s";
      };
      wantedBy = [ "default.target" ];
    };



    # Configure keymap in X11
    services.xserver.xkb = {
        layout = "gb";
        variant = "";
    };

    # Configure console keymap
    console.keyMap = "uk";

    # Enable CUPS to print documents.
    services.printing.enable = true;

    services.avahi = {
        enable = true;
        nssmdns4 = true;
        openFirewall = true;
    };


    security.sudo.extraConfig = ''
        Defaults        timestamp_timeout=30
        kavya ALL=(ALL) NOPASSWD: /nix/store/ab9zmvn353kxdci7kn9g7n5vw51yriy4-profile-sync-daemon-6.50/bin/psd-overlay-helper
    '';

    # Enable sound with pipewire.
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
        extraGroups = [ "networkmanager" "wheel" "docker" ];
        packages = with pkgs; [
        kdePackages.kate
        #  thunderbird
        ];
    };


    # Install firefox.
    programs.firefox.enable = true;
    programs.steam.enable = true;
    virtualisation.docker.rootless = {
        enable = true;
        setSocketVariable = true;
    };

    # Allow unfree packages
    nixpkgs.config.allowUnfree = true;
    nixpkgs.config.segger-jlink.acceptLicense = true;

    nix = {

        # This will additionally add your inputs to the system's legacy channels
        # Making legacy nix commands consistent as well, awesome!
        nixPath = lib.mapAttrsToList (key: value: "${key}=${value.to.path}") config.nix.registry;

        settings = {
        # Enable flakes and new 'nix' command
        experimental-features = "nix-command flakes";
        # Deduplicate and optimize nix store
        auto-optimise-store = true;
        };
    };
    # List packages installed in system profile. To search, run:
    # $ nix search wget

    environment.sessionVariables = {
        GSETTINGS_SCHEMA_DIR="${appmenu-gtk3-module}/share/gsettings-schemas/${appmenu-gtk3-module.name}/glib-2.0/schemas";
        __EGL_VENDOR_LIBRARY_FILENAMES="${pkgs.mesa.drivers}/share/glvnd/egl_vendor.d/50_mesa.json";
        __GLX_VENDOR_LIBRARY_NAME="mesa";
        GTK_MODULES="appmenu-gtk-module";

    };

    environment.systemPackages = with pkgs; [
    #  vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
        kdePackages.yakuake
        vscode
        vesktop
        kdePackages.filelight
        kdePackages.kglobalaccel
        heroic
        kicad
        brave
        picoscope
        libreoffice-qt6-fresh
        nrf-command-line-tools
        nrfconnect
        catppuccin-kde
        catppuccin-sddm
        catppuccin-gtk
        catppuccin-kvantum
        catppuccin-cursors
        catppuccin-papirus-folders
        catppuccin-qt5ct
        vscode-extensions.catppuccin.catppuccin-vsc
        vscode-extensions.catppuccin.catppuccin-vsc-icons
        tela-circle-icon-theme
        powertop
        linuxKernel.packages.linux_zen.cpupower
        linuxKernel.packages.linux_zen.ddcci-driver
        zsh
        zsh-completions
        zsh-powerlevel9k
        zsh-autocomplete
        htop
        vlc
        qbittorrent
        rustup
        rustc
        awscli2
        nodePackages.aws-cdk
        nodejs_22
        anki-bin
        git
        libgcc
        gcc
        wget
        curl
        roon-tui
        parsec-bin
        kdePackages.plasma-browser-integration
        kdePackages.sddm-kcm
        ddcutil
        kdePackages.systemsettings
        kdePackages.qtstyleplugin-kvantum
        kdePackages.kirigami
        kdePackages.kirigami-addons
        kmail
        distrobox
        profile-sync-daemon
        glib
        tidal-hifi
        cifs-utils
        appmenu-gtk3-module
        gsettings-desktop-schemas
    ];



    nixpkgs.config.permittedInsecurePackages = [
                    "segger-jlink-qt4-796s"
    ];

    fonts.packages = with pkgs; [
        fira-code-symbols
        fira-code
        redhat-official-fonts
    ];

    programs.dconf.enable = true;
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
