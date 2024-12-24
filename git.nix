{ config, pkgs, ... }:

{
    programs.git = {
        enable = true;
        userName = "Yuvraj D";
        userEmail = "yuvraj.dubey@altus.ventures";
        extraConfig = {
            credential = {
                credentialStore = "secretservice";
                helper = "${pkgs.git-credential-manager}/bin/git-credential-manager";
            };
        };
    };
}
