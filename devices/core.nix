# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).
{ config, lib, pkgs, modulesPath, targetDevice, ... }:


let
    core_root = builtins.toString ./.;
    nix-snapshotter = import (
        builtins.fetchTarball "https://github.com/pdtpartners/nix-snapshotter/archive/main.tar.gz"
    );
    appmenu-gtk3-module = (pkgs.callPackage ./appmenu.nix {});
    opera-gx = (pkgs.callPackage ./opera_gx.nix {});
in
{
    imports =
        [ # Include the specified device's configuration.
        
            (core_root + "/${targetDevice}/configuration.nix")
            nix-snapshotter.nixosModules.default
        ];

    nixpkgs.config.packageOverrides = pkgs: {
        nur = import (builtins.fetchTarball "https://github.com/nix-community/NUR/archive/master.tar.gz") {
            inherit pkgs;
        };
    };

    nixpkgs.overlays = [ nix-snapshotter.overlays.default ];
    #boot.kernelParams = [];

    # (3) Enable service.
    virtualisation.containerd = {
        enable = true;
        nixSnapshotterIntegration = true;
    };
    services.nix-snapshotter = {
        enable = true;
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
    networking.networkmanager.wifi.backend = "iwd";
    networking.networkmanager.dns = "systemd-resolved";
    services.resolved.enable = true;

    networking.wireless.iwd.settings = {
        Scan = {
            DisablePeriodicScan = true;
            DisableRoamingScan = true;
        };
    };

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

    services.udev.extraRules = ''
        SUBSYSTEM!="usb|usb_device", GOTO="xmos_rules_end"
        ACTION!="add", GOTO="xmos_rules_end"

        # 20b1:f7d4 - XMOS XTAG-3
        ATTRS{idVendor}=="20b1", ATTRS{idProduct}=="f7d4", MODE="0666", SYMLINK="xtag3-%n"

        # 20b1:f7d5 - XMOS XTAG-4
        ATTRS{idVendor}=="20b1", ATTRS{idProduct}=="f7d5", MODE="0666", SYMLINK="xtag4-%n"

        LABEL="xmos_rules_end"

        SUBSYSTEM=="usb", ATTRS{idVendor}=="1a86", ATTRS{idProduct}=="5512", MODE="0666"

        # CP210X USB UART
        ATTRS{idVendor}=="10c4", ATTRS{idProduct}=="ea[67][013]", MODE:="0666", ENV{ID_MM_DEVICE_IGNORE}="1", ENV{ID_MM_PORT_IGNORE}="1"
        ATTRS{idVendor}=="10c4", ATTRS{idProduct}=="80a9", MODE:="0666", ENV{ID_MM_DEVICE_IGNORE}="1", ENV{ID_MM_PORT_IGNORE}="1"

        # FT231XS USB UART
        ATTRS{idVendor}=="0403", ATTRS{idProduct}=="6015", MODE:="0666", ENV{ID_MM_DEVICE_IGNORE}="1", ENV{ID_MM_PORT_IGNORE}="1"

        # Prolific Technology, Inc. PL2303 Serial Port
        ATTRS{idVendor}=="067b", ATTRS{idProduct}=="2303", MODE:="0666", ENV{ID_MM_DEVICE_IGNORE}="1", ENV{ID_MM_PORT_IGNORE}="1"

        # QinHeng Electronics HL-340 USB-Serial adapter
        ATTRS{idVendor}=="1a86", ATTRS{idProduct}=="7523", MODE:="0666", ENV{ID_MM_DEVICE_IGNORE}="1", ENV{ID_MM_PORT_IGNORE}="1"
        # QinHeng Electronics CH343 USB-Serial adapter
        ATTRS{idVendor}=="1a86", ATTRS{idProduct}=="55d3", MODE:="0666", ENV{ID_MM_DEVICE_IGNORE}="1", ENV{ID_MM_PORT_IGNORE}="1"
        # QinHeng Electronics CH9102 USB-Serial adapter
        ATTRS{idVendor}=="1a86", ATTRS{idProduct}=="55d4", MODE:="0666", ENV{ID_MM_DEVICE_IGNORE}="1", ENV{ID_MM_PORT_IGNORE}="1"

        # Arduino boards
        ATTRS{idVendor}=="2341", ATTRS{idProduct}=="[08][023]*", MODE:="0666", ENV{ID_MM_DEVICE_IGNORE}="1", ENV{ID_MM_PORT_IGNORE}="1"
        ATTRS{idVendor}=="2a03", ATTRS{idProduct}=="[08][02]*", MODE:="0666", ENV{ID_MM_DEVICE_IGNORE}="1", ENV{ID_MM_PORT_IGNORE}="1"

        # Arduino SAM-BA
        ATTRS{idVendor}=="03eb", ATTRS{idProduct}=="6124", MODE:="0666", ENV{ID_MM_DEVICE_IGNORE}="1", ENV{MTP_NO_PROBE}="1"

        # Digistump boards
        ATTRS{idVendor}=="16d0", ATTRS{idProduct}=="0753", MODE:="0666", ENV{ID_MM_DEVICE_IGNORE}="1", ENV{ID_MM_PORT_IGNORE}="1"

        # Maple with DFU
        ATTRS{idVendor}=="1eaf", ATTRS{idProduct}=="000[34]", MODE:="0666", ENV{ID_MM_DEVICE_IGNORE}="1", ENV{ID_MM_PORT_IGNORE}="1"

        # USBtiny
        ATTRS{idProduct}=="0c9f", ATTRS{idVendor}=="1781", MODE:="0666", ENV{ID_MM_DEVICE_IGNORE}="1", ENV{ID_MM_PORT_IGNORE}="1"

        # USBasp V2.0
        ATTRS{idVendor}=="16c0", ATTRS{idProduct}=="05dc", MODE:="0666", ENV{ID_MM_DEVICE_IGNORE}="1", ENV{ID_MM_PORT_IGNORE}="1"

        # Teensy boards
        ATTRS{idVendor}=="16c0", ATTRS{idProduct}=="04[789B]?", ENV{ID_MM_DEVICE_IGNORE}="1", ENV{ID_MM_PORT_IGNORE}="1"
        ATTRS{idVendor}=="16c0", ATTRS{idProduct}=="04[789A]?", ENV{MTP_NO_PROBE}="1"
        SUBSYSTEMS=="usb", ATTRS{idVendor}=="16c0", ATTRS{idProduct}=="04[789ABCD]?", MODE:="0666"
        KERNEL=="ttyACM*", ATTRS{idVendor}=="16c0", ATTRS{idProduct}=="04[789B]?", MODE:="0666"

        # TI Stellaris Launchpad
        ATTRS{idVendor}=="1cbe", ATTRS{idProduct}=="00fd", MODE="0666", ENV{ID_MM_DEVICE_IGNORE}="1", ENV{ID_MM_PORT_IGNORE}="1"

        # TI MSP430 Launchpad
        ATTRS{idVendor}=="0451", ATTRS{idProduct}=="f432", MODE="0666", ENV{ID_MM_DEVICE_IGNORE}="1", ENV{ID_MM_PORT_IGNORE}="1"

        # GD32V DFU Bootloader
        ATTRS{idVendor}=="28e9", ATTRS{idProduct}=="0189", MODE="0666", ENV{ID_MM_DEVICE_IGNORE}="1", ENV{ID_MM_PORT_IGNORE}="1"

        # FireBeetle-ESP32
        ATTRS{idVendor}=="1a86", ATTRS{idProduct}=="7522", MODE="0666", ENV{ID_MM_DEVICE_IGNORE}="1", ENV{ID_MM_PORT_IGNORE}="1"

        # Wio Terminal
        ATTRS{idVendor}=="2886", ATTRS{idProduct}=="[08]02d", MODE="0666", ENV{ID_MM_DEVICE_IGNORE}="1", ENV{ID_MM_PORT_IGNORE}="1"

        # Raspberry Pi Pico
        ATTRS{idVendor}=="2e8a", ATTRS{idProduct}=="[01]*", MODE:="0666", ENV{ID_MM_DEVICE_IGNORE}="1", ENV{ID_MM_PORT_IGNORE}="1"

        # AIR32F103
        ATTRS{idVendor}=="0d28", ATTRS{idProduct}=="0204", MODE="0666", ENV{ID_MM_DEVICE_IGNORE}="1", ENV{ID_MM_PORT_IGNORE}="1"

        # STM32 virtual COM port
        ATTRS{idVendor}=="0483", ATTRS{idProduct}=="5740", MODE="0666", ENV{ID_MM_DEVICE_IGNORE}="1", ENV{ID_MM_PORT_IGNORE}="1"

        #
        # Debuggers
        #

        # Black Magic Probe
        SUBSYSTEM=="tty", ATTRS{interface}=="Black Magic GDB Server", MODE="0666", ENV{ID_MM_DEVICE_IGNORE}="1", ENV{ID_MM_PORT_IGNORE}="1"
        SUBSYSTEM=="tty", ATTRS{interface}=="Black Magic UART Port", MODE="0666", ENV{ID_MM_DEVICE_IGNORE}="1", ENV{ID_MM_PORT_IGNORE}="1"

        # opendous and estick
        ATTRS{idVendor}=="03eb", ATTRS{idProduct}=="204f", MODE="0666", ENV{ID_MM_DEVICE_IGNORE}="1", ENV{ID_MM_PORT_IGNORE}="1"

        # Original FT232/FT245/FT2232/FT232H/FT4232
        ATTRS{idVendor}=="0403", ATTRS{idProduct}=="60[01][104]", MODE="0666", ENV{ID_MM_DEVICE_IGNORE}="1", ENV{ID_MM_PORT_IGNORE}="1"

        # DISTORTEC JTAG-lock-pick Tiny 2
        ATTRS{idVendor}=="0403", ATTRS{idProduct}=="8220", MODE="0666", ENV{ID_MM_DEVICE_IGNORE}="1", ENV{ID_MM_PORT_IGNORE}="1"

        # TUMPA, TUMPA Lite
        ATTRS{idVendor}=="0403", ATTRS{idProduct}=="8a9[89]", MODE="0666", ENV{ID_MM_DEVICE_IGNORE}="1", ENV{ID_MM_PORT_IGNORE}="1"

        # XDS100v2
        ATTRS{idVendor}=="0403", ATTRS{idProduct}=="a6d0", MODE="0666", ENV{ID_MM_DEVICE_IGNORE}="1", ENV{ID_MM_PORT_IGNORE}="1"

        # Xverve Signalyzer Tool (DT-USB-ST), Signalyzer LITE (DT-USB-SLITE)
        ATTRS{idVendor}=="0403", ATTRS{idProduct}=="bca[01]", MODE="0666", ENV{ID_MM_DEVICE_IGNORE}="1", ENV{ID_MM_PORT_IGNORE}="1"

        # TI/Luminary Stellaris Evaluation Board FTDI (several)
        ATTRS{idVendor}=="0403", ATTRS{idProduct}=="bcd[9a]", MODE="0666", ENV{ID_MM_DEVICE_IGNORE}="1", ENV{ID_MM_PORT_IGNORE}="1"

        # egnite Turtelizer 2
        ATTRS{idVendor}=="0403", ATTRS{idProduct}=="bdc8", MODE="0666", ENV{ID_MM_DEVICE_IGNORE}="1", ENV{ID_MM_PORT_IGNORE}="1"

        # Section5 ICEbear
        ATTRS{idVendor}=="0403", ATTRS{idProduct}=="c14[01]", MODE="0666", ENV{ID_MM_DEVICE_IGNORE}="1", ENV{ID_MM_PORT_IGNORE}="1"

        # Amontec JTAGkey and JTAGkey-tiny
        ATTRS{idVendor}=="0403", ATTRS{idProduct}=="cff8", MODE="0666", ENV{ID_MM_DEVICE_IGNORE}="1", ENV{ID_MM_PORT_IGNORE}="1"

        # TI ICDI
        ATTRS{idVendor}=="0451", ATTRS{idProduct}=="c32a", MODE="0666", ENV{ID_MM_DEVICE_IGNORE}="1", ENV{ID_MM_PORT_IGNORE}="1"

        # STLink probes
        ATTRS{idVendor}=="0483", MODE="0666", ENV{ID_MM_DEVICE_IGNORE}="1", ENV{ID_MM_PORT_IGNORE}="1"

        # Hilscher NXHX Boards
        ATTRS{idVendor}=="0640", ATTRS{idProduct}=="0028", MODE="0666", ENV{ID_MM_DEVICE_IGNORE}="1", ENV{ID_MM_PORT_IGNORE}="1"

        # Hitex probes
        ATTRS{idVendor}=="0640", MODE="0666", ENV{ID_MM_DEVICE_IGNORE}="1", ENV{ID_MM_PORT_IGNORE}="1"

        # Altera USB Blaster
        ATTRS{idVendor}=="09fb", ATTRS{idProduct}=="6001", MODE="0666", ENV{ID_MM_DEVICE_IGNORE}="1", ENV{ID_MM_PORT_IGNORE}="1"

        # Amontec JTAGkey-HiSpeed
        ATTRS{idVendor}=="0fbb", ATTRS{idProduct}=="1000", MODE="0666", ENV{ID_MM_DEVICE_IGNORE}="1", ENV{ID_MM_PORT_IGNORE}="1"

        # SEGGER J-Link
        ATTRS{idVendor}=="1366", MODE="0666", ENV{ID_MM_DEVICE_IGNORE}="1", ENV{ID_MM_PORT_IGNORE}="1"

        # Raisonance RLink
        ATTRS{idVendor}=="138e", ATTRS{idProduct}=="9000", MODE="0666", ENV{ID_MM_DEVICE_IGNORE}="1", ENV{ID_MM_PORT_IGNORE}="1"

        # Debug Board for Neo1973
        ATTRS{idVendor}=="1457", ATTRS{idProduct}=="5118", MODE="0666", ENV{ID_MM_DEVICE_IGNORE}="1", ENV{ID_MM_PORT_IGNORE}="1"

        # Olimex probes
        ATTRS{idVendor}=="15ba", MODE="0666", ENV{ID_MM_DEVICE_IGNORE}="1", ENV{ID_MM_PORT_IGNORE}="1"

        # USBprog with OpenOCD firmware
        ATTRS{idVendor}=="1781", ATTRS{idProduct}=="0c63", MODE="0666", ENV{ID_MM_DEVICE_IGNORE}="1", ENV{ID_MM_PORT_IGNORE}="1"

        # TI/Luminary Stellaris In-Circuit Debug Interface (ICDI) Board
        ATTRS{idVendor}=="1cbe", ATTRS{idProduct}=="00fd", MODE="0666", ENV{ID_MM_DEVICE_IGNORE}="1", ENV{ID_MM_PORT_IGNORE}="1"

        # Marvell Sheevaplug
        ATTRS{idVendor}=="9e88", ATTRS{idProduct}=="9e8f", MODE="0666", ENV{ID_MM_DEVICE_IGNORE}="1", ENV{ID_MM_PORT_IGNORE}="1"

        # Keil Software, Inc. ULink
        ATTRS{idVendor}=="c251", ATTRS{idProduct}=="2710", MODE="0666", ENV{ID_MM_DEVICE_IGNORE}="1", ENV{ID_MM_PORT_IGNORE}="1"

        # CMSIS-DAP compatible adapters
        ATTRS{product}=="*CMSIS-DAP*", MODE="0666", ENV{ID_MM_DEVICE_IGNORE}="1", ENV{ID_MM_PORT_IGNORE}="1"

        # Atmel AVR Dragon
        ATTRS{idVendor}=="03eb", ATTRS{idProduct}=="2107", MODE="0666", ENV{ID_MM_DEVICE_IGNORE}="1", ENV{ID_MM_PORT_IGNORE}="1"

        # Espressif USB JTAG/serial debug unit
        ATTRS{idVendor}=="303a", ATTRS{idProduct}=="1001", MODE="0666", ENV{ID_MM_DEVICE_IGNORE}="1", ENV{ID_MM_PORT_IGNORE}="1"

        # Zephyr framework USB CDC-ACM
        ATTRS{idVendor}=="2fe3", ATTRS{idProduct}=="0100", MODE="0666", ENV{ID_MM_DEVICE_IGNORE}="1", ENV{ID_MM_PORT_IGNORE}="1"

    '';


    services.pipewire = {
        enable = true;
        alsa.enable = true;
        alsa.support32Bit = true;
        pulse.enable = true;
        # If you want to use JACK applications, uncomment this
        #jack.enable = true;

        raopOpenFirewall = true;
        # opens UDP ports 6001-6002
        extraConfig.pipewire = {
            "10-airplay" = {
            "context.modules" = [
                {
                name = "libpipewire-module-raop-discover";

                # increase the buffer size if you get dropouts/glitches
                args = {
                   "raop.latency.ms" = 100;
                };

                }
            ];
            };
        };

        wireplumber.extraConfig = {
            "monitor.bluez.properties" = {
                "bluez5.enable-sbc-xq" = true;
                "bluez5.enable-msbc" = true;
                "bluez5.enable-hw-volume" = true;
                "bluez5.roles" = [ "hsp_hs" "hsp_ag" "hfp_hf" "hfp_ag" ];
            };
        };

    };

    services.pulseaudio.enable = false;
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

    hardware.i2c.enable = true;

    # Enable the X11 windowing system.
    # You can disable this if you're only using the Wayland session.
    services.xserver.enable = true;

    # Enable the KDE Plasma Desktop Environment.
    services.displayManager.sddm.enable = true;
    services.desktopManager.plasma6.enable = true;
    
    services.psd.enable = true;

    systemd.user.services.yakuake = {
      environment= lib.mkForce {
        PATH="/run/wrappers/bin:/home/kavya/.nix-profile/bin:/nix/profile/bin:/home/kavya/.local/state/nix/profile/bin:/etc/profiles/per-user/kavya/bin:/nix/var/nix/profiles/default/bin:/run/current-system/sw/bin";
        WAYLAND_DISPLAY="wayland-0";
        DISPLAY=":1";
        XAUTHORITY="/run/user/1000/xauth_nYrLEM";
      };
      enable = true;
      description = "Open Yakuake at boot";
      serviceConfig = {
          ExecStart = "/run/current-system/sw/bin/yakuake";
          Restart = "on-failure";
          RestartSec = "5s";
      };
      wantedBy = [ "plasma-workspace.target" ];
    };


    systemd.services.poweroptimise = {
      enable = true;
      description = "Apply power optimisations at boot";
      serviceConfig = {
          RemainAfterExit=true;
          Type="oneshot";
          User="root";
          ExecStart = "${pkgs.bash}/bin/bash ${core_root}/${targetDevice}/powertop-tune.sh";
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


    # Enable touchpad support (enabled default in most desktopManager).
    # services.xserver.libinput.enable = true;

    # Define a user account. Don't forget to set a password with ‘passwd’.
    users.users.kavya = {
        isNormalUser = true;
        description = "KD";
        extraGroups = [ "networkmanager" "wheel" "docker" "i2c" ];
        packages = with pkgs; [
        kdePackages.kate
        #  thunderbird
        ];
    };


    # Install firefox.
    programs.steam.enable = true;
    programs.kdeconnect.enable = true;
    programs.partition-manager.enable = true;
    virtualisation.docker.enable = true;

    virtualisation.docker.rootless = {
        enable = true;
        setSocketVariable = true;
    };

    # Allow unfree packages
    nixpkgs.config.allowUnfree = true;
#     programs.nix-ld.enable = true;
#     programs.nix-ld.libraries = with pkgs; [
#         cmake
#         libtinfo
#     ];
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
        __EGL_VENDOR_LIBRARY_FILENAMES="${pkgs.mesa}/share/glvnd/egl_vendor.d/50_mesa.json";
        __GLX_VENDOR_LIBRARY_NAME="mesa";
        GTK_MODULES="appmenu-gtk-module";
        SSH_AUTH_SOCK="/home/kavya/.bitwarden-ssh-agent.sock";
    };

    programs.direnv = {
        enable = true;
        enableBashIntegration = true;
        loadInNixShell = true;
        nix-direnv.enable = true;
    };

    environment.systemPackages = with pkgs; [
    #  vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
        kdePackages.yakuake
        vscode
        vesktop
        davinci-resolve
        bitwarden-desktop
        bitwarden-cli
        kdePackages.filelight
        kdePackages.kglobalaccel
        heroic
        kicad
        jetbrains.pycharm
        nixd
        vscode-json-languageserver
        brave
        picoscope
        helix
        easyeffects
        libreoffice-qt6-fresh
        nrf-command-line-tools
        nrfconnect
        platformio
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
        ddcutil
        zsh
        zsh-completions
        zsh-powerlevel9k
        zsh-autocomplete
        htop
        pay-respects
        vlc
        qbittorrent
        rustup
        rustc
        awscli2
        aws-cdk-cli
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
        kdePackages.kio-fuse
        protonvpn-gui
        kdePackages.sddm-kcm
        ddcutil
        kdePackages.systemsettings
        kdePackages.qtstyleplugin-kvantum
        kdePackages.kirigami
        kdePackages.kirigami-addons
        kdePackages.kontact
        kdePackages.kmail-account-wizard
        kdePackages.kontactinterface
        distrobox
        profile-sync-daemon
        glib
        cifs-utils
        wgnord
        appmenu-gtk3-module
        opera-gx
        gsettings-desktop-schemas
        code-cursor
        telegram-desktop
        appimage-run
    ];



    nixpkgs.config.permittedInsecurePackages = [
                    "segger-jlink-qt4-874"
    ];

    fonts.packages = with pkgs; [
        fira-code-symbols
        fira-code
        noto-fonts-lgc-plus
        redhat-official-fonts
        inter
        meslo-lgs-nf
    ];

    fonts.fontconfig = {
        defaultFonts = {
            serif = [ "Noto Serif" ];
            sansSerif = [ "Red Hat Text" ];
            monospace = [ "Fira Code" ];
        };
        useEmbeddedBitmaps = true;
    };

    programs.dconf.enable = true;



    # Some programs need SUID wrappers, can be configured further or are
    # started in user sessions.
    # programs.mtr.enable = true;
    # programs.gnupg.agent = {
    #   enable = true;
    #   enableSSHSupport = true;
    # };

    # List services that you want to enable:
    programs.ssh.setXAuthLocation = true;
    programs.ssh.forwardX11 = true;
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
