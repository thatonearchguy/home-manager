{ config, pkgs, ... }:

let
    config_root = builtins.toString ./.;

in
{
    home.file.".config/OpenRGB/OpenRGB.json".source = (config_root + "/OpenRGB.json");
    home.file.".config/OpenRGB/bikb.orp".source = (config_root + "/bikb.orp");
}
