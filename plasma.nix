{ config, pkgs, ... }:

{
    qt = {
        enable = true;
        style.name = "kvantum";

    };

    xdg.configFile."Kvantum/kvantum.kvconfig".source = (pkgs.formats.ini {}).generate "kvantum.kvconfig" {
        General.theme = "Catppuccin-Frappe-Blue";
    };
    programs.konsole = {
        enable = true;
        defaultProfile = "NixGenerated Profile";
        profiles = {
            custom = {
                name = "NixGenerated Profile";
                colorScheme = "Catppuccin-Frappe";
                command = "bash";
                font = {
                name = "Fira Code";
                size = 10;
                };
            };
        };
    };
    programs.plasma = {
        enable = true;
        workspace = {
            clickItemTo = "select";
            lookAndFeel = "Catppuccin-Frappe-Blue";
            cursor = {
                theme = "catppuccin-frappe-blue-cursors";
                size = 24;
            };
            iconTheme = "Tela-circle-dark";
            wallpaper = "/home/kavya/.config/home-manager/wallpaper.jpg";
        };

        fonts = {
            general = {
                family = "Red Hat Text";
                pointSize = 10;
            };
        };
        
        panels = [
        # Windows-like panel at the bottom
        {
            location = "bottom";
            height = 44;
            hiding = "dodgewindows";
            floating = true;
            lengthMode = "fit";
            alignment = "center";
            widgets = [
            {
                name = "org.kde.plasma.icontasks";
                config = {
                    General.launchers = [
                        "applications:org.kde.dolphin.desktop"
                        "applications:org.kde.konsole.desktop"
                        "applications:firefox.desktop"
                        "applications:code.desktop"
                        "applications:org.kicad.kicad.desktop"
                        "applications:vesktop.desktop"
                        "applications:com.heroicgameslauncher.hgl.desktop"
                        "applications:systemsettings.desktop"

                    ];
                };
            }

            ];
        }
        # Global menu at the top
        {
            location = "top";
            height = 26;
            floating = true;
            widgets = [
            "org.kde.plasma.kickoff"
            "org.kde.plasma.marginsseparator"
            "org.kde.plasma.appmenu"
            "org.kde.plasma.marginsseparator"
            "org.kde.plasma.panelspacer"
            {
                systemTray.items = {
                # We explicitly show bluetooth and battery
                shown = [
                    "org.kde.plasma.networkmanagement"
                    "org.kde.plasma.bluetooth"
                    "org.kde.plasma.battery"
                    "org.kde.plasma.volume"
                ];
                # And explicitly hide networkmanagement and volume
                hidden = [
                    "org.kde.plasma.clipboard"
                    "org.kde.plasma.notifications"
                    "org.kde.plasma.brightness"
                    "org.kde.yakuake"

                ];
                };
            }
            "org.kde.plasma.digitalclock"

            ];
        }
        ];



        configFile = {
            "baloofilerc"."Basic Settings"."Indexing-Enabled" = false;
            "kwinrc"."org.kde.kdecoration2"."ButtonsOnLeft" = "SF";
            "kwinrc"."Desktops"."Number" = {
                value = 4;
                # Forces kde to not change this value (even through the settings app).
                immutable = true;
            };
            kscreenlockerrc = {
                Greeter.WallpaperPlugin = "org.kde.image";
                "Greeter/Wallpaper/org.kde.image/General".Image = "/home/kavya/.config/home-manager/wallpaper.jpg";
            };
        };
    };
}
