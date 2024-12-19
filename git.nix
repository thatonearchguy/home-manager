{ config, pkgs, ... }:

{
    programs.git = {
        enable = true;
        userName = "Yuvraj D";
        userEmail = "karandubey2911@gmail.com";
        extraConfig = {
            credential = {
                credentialStore = "secretservice";
                helper = "${pkgs.git-credential-manager}";
            };
        };
    };
}
