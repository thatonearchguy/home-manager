{ config, pkgs, ... }:

{
    programs.git = {
        enable = true;
        userName = "Yuvraj D";
        userEmail = "karandubey2911@gmail.com";
        extraConfig = {
            credential = {
                credentialStore = "secretservice";
                helper = "${pkgs.nur.repos.utybo.git-credential-manager}/bin/git-credential-manager";
            };
        };
    };
}
