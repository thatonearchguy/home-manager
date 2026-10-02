{ config, pkgs, hostName, ... }:

let
    lock-false = {
      Value = false;
      Status = "locked";
    };
    lock-true = {
      Value = true;
      Status = "locked";
    };
in
{
  nixpkgs.config.packageOverrides = pkgs: {
    nur = import (builtins.fetchTarball "https://github.com/nix-community/NUR/archive/master.tar.gz") {
      inherit pkgs;
    };
  };

  home.username = "kavya";
  home.homeDirectory = "/home/kavya";

  home.file.".local/share/konsole/Catppuccin-Frappe.colorscheme".source = ./Catppuccin-Frappe.colorscheme;
  home.file.".config/yakuakerc".source = ./yakuakerc;
  # link the configuration file in current directory to the specified location in home directory
  # home.file.".config/i3/f.jpg".source = ./wallpaper.jpg;
  home.file.".local/share/yakuake/skins" = {
    source = ./skins;
    recursive = true;
  };

  home.file.".config/kate/lspclient/settings.json".source = ./kate-settings.json;

  home.sessionVariables.NIXOS_OZONE_WL = "1";

  services.arrpc.enable = true;


  # link all files in `./scripts` to `~/.config/i3/scripts`
  # home.file.".config/i3/scripts" = {
  #   source = ./scripts;
  #   recursive = true;   # link recursively
  #   executable = true;  # make all files executable
  # };

  # encode the file content in nix configuration file directly
  # home.file.".xxx".text = ''
  #     xxx
  # '';

  # set cursor size and dpi for 4k monitor
  xresources.properties = {
    "Xcursor.size" = 16;
    "Xft.dpi" = 172;
  };

  # Packages that should be installed to the user profile.
  home.packages = with pkgs; [
    # here is some command line tools I use frequently
    # feel free to add your own or remove some of them

    fastfetch
    nnn # terminal file manager
    python3

    # archives
    zip
    xz
    unzip
    p7zip

    # utils
    ripgrep # recursively searches directories for a regex pattern
    jq # A lightweight and flexible command-line JSON processor
    yq-go # yaml processor https://github.com/mikefarah/yq
    eza # A modern replacement for ‘ls’
    fzf # A command-line fuzzy finder
    helix
    nix-index
    libdbusmenu-gtk3

    # networking tools
    mtr # A network diagnostic tool    iperf3
    dnsutils  # `dig` + `nslookup`
    ldns # replacement of `dig`, it provide the command `drill`
    aria2 # A lightweight multi-protocol & multi-source command-line download utility
    socat # replacement of openbsd-netcat
    nmap # A utility for network discovery and security auditing
    ipcalc  # it is a calculator for the IPv4/v6 addresses
    xournalpp

    # misc
    cowsay
    file
    which
    tree
    gnused
    gnutar
    gawk
    zstd
    gnupg

    # nix related
    #
    # it provides the command `nom` works just like `nix`
    # with more details log output
    nix-output-monitor

    # productivity
    hugo # static site generator
    glow # markdown previewer in terminal
    bat #rust rewrite of cat with syntax highlighting

    btop  # replacement of htop/nmon
    iotop # io monitoring
    iftop # network monitoring

    # system call monitoring
    strace # system call monitoring
    ltrace # library call monitoring
    lsof # list open files

    # system tools
    sysstat
    lm_sensors # for `sensors` command
    ethtool
    pciutils # lspci
    usbutils # lsusb
    (catppuccin-kvantum.override {
      accent = "blue";
      variant = "frappe";
    })
    catppuccin-cursors.frappeBlue
  ];

  programs.pay-respects.enableZshIntegration = true;

  programs.nixcord = {
    enable = true;
    discord.equicord.enable = true;
    config.themeLinks = [ "https://raw.githubusercontent.com/catppuccin/discord/refs/heads/main/themes/frappe.theme.css" ];
    config.enabledThemeLinks = [ "https://raw.githubusercontent.com/catppuccin/discord/refs/heads/main/themes/frappe.theme.css" ];
    config.plugins = {
      hideMedia.enable = true;
      altKrispSwitch.enable = true;
      betterActivities.enable = true;
      betterAudioPlayer.enable = true;
      streamingCodecDisabler.enable = true;
      translatePlus.enable = true;
      alwaysTrust.enable = true;
      anonymiseFileNames.enable = true;
      betterFolders.enable = true;
      blurNsfw.enable = true;
      clearUrls.enable = true;
      colorSighted.enable = true;
      crashHandler.enable = true;
      fakeNitro.enable = true;
      fixYoutubeEmbeds.enable = true;
      noDevtoolsWarning.enable = true;
      noTrack.enable = true;
      noTypingAnimation.enable = true;
      settings.enable = true;
      supportHelper.enable = true;
      typingIndicator.enable = true;
      webContextMenus = {
        enable = true;
        addBack = true;
      };
      webKeybinds.enable = true;
      webScreenShareFixes.enable = true;
    };
  };

  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;

    initContent = ''
      [[ ! -f /home/kavya/.config/home-manager/p10k-config/p10k.zsh ]] || source /home/kavya/.config/home-manager/p10k-config/p10k.zsh

    '';

    zplug = {
      enable = true;
      plugins = [
        { name = "zsh-users/zsh-autosuggestions"; } # Simple plugin installation
        { name = "romkatv/powerlevel10k"; tags = [ as:theme depth:1 ]; }
        { name = "plugins/git"; tags = [from:oh-my-zsh]; }
        { name = "plugins/battery"; tags = [from:oh-my-zsh]; }
        { name = "plugins/redis-cli"; tags = [from:oh-my-zsh]; }
        { name = "plugins/rsync"; tags = [from:oh-my-zsh]; }
        { name = "plugins/npm"; tags = [from:oh-my-zsh]; }
        { name = "plugins/python"; tags = [from:oh-my-zsh]; }
        { name = "plugins/github"; tags = [from:oh-my-zsh]; }
        { name = "plugins/emoji"; tags = [from:oh-my-zsh]; }
        { name = "plugins/dotenv"; tags = [from:oh-my-zsh]; }
        { name = "plugins/docker-compose"; tags = [from:oh-my-zsh]; }
        { name = "plugins/docker"; tags = [from:oh-my-zsh]; }
        { name = "plugins/aws"; tags = [from:oh-my-zsh]; }
        { name = "plugins/aliases"; tags = [from:oh-my-zsh]; }
        { name = "plugins/alias-finder"; tags = [from:oh-my-zsh]; }
        { name = "./p10k-config/p10k.zsh"; tags = [from:local]; }
      ];
    };


    shellAliases = {
      k = "kubectl";
      urldecode = "python3 -c 'import sys, urllib.parse as ul; print(ul.unquote_plus(sys.stdin.read()))'";
      urlencode = "python3 -c 'import sys, urllib.parse as ul; print(ul.quote_plus(sys.stdin.read()))'";
      cat = "bat";
      rebuild = "sudo nixos-rebuild switch --impure --flake /home/kavya/.config/home-manager/devices#${hostName}";
      pacman-create = "sh /home/kavya/.config/home-manager/pacman-folder-create.sh";
      pacman-destroy = "sh /home/kavya/.config/home-manager/pacman-folder-destroy.sh";
    };

    history.size = 10000;
  };



  programs.bash = {
    enable = true;
    enableCompletion = true;
    # TODO add your custom bashrc here
    bashrcExtra = ''
      export PATH="$PATH:$HOME/bin:$HOME/.local/bin:$HOME/go/bin"
    '';

    # set some aliases, feel free to add more or remove some
    shellAliases = {
      k = "kubectl";
      urldecode = "python3 -c 'import sys, urllib.parse as ul; print(ul.unquote_plus(sys.stdin.read()))'";
      urlencode = "python3 -c 'import sys, urllib.parse as ul; print(ul.quote_plus(sys.stdin.read()))'";
      cat = "${pkgs.bat}/bin/bat";
      rebuild = "sudo nixos-rebuild switch --impure --flake /home/kavya/.config/home-manager/devices#${hostName}";
      pacman-create = "sh /home/kavya/.config/home-manager/pacman-folder-create.sh";
      pacman-destroy = "sh /home/kavya/.config/home-manager/pacman-folder-destroy.sh";
    };
  };

  # This value determines the home Manager release that your
  # configuration is compatible with. This helps avoid breakage
  # when a new home Manager release introduces backwards
  # incompatible changes.
  #
  # You can update home Manager without changing this value. See
  # the home Manager release notes for a list of state version
  # changes in each release.
  home.stateVersion = "24.11";

  # Let home Manager install and manage itself.
  programs.home-manager.enable = true;

  imports = [
    ./firefox.nix
    ./plasma.nix
    ./git.nix
    ./devices/${hostName}/home.nix
  ];

}
