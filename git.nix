{ config, pkgs, ... }:

{
    programs.git = {
        enable = true;
        settings = {
            user = {
                name = "Yuvraj D";
                email = "karandubey2911@gmail.com";
            };
            credential = {
                credentialStore = "secretservice";
                helper = "${pkgs.git-credential-manager}/bin/git-credential-manager";
            };
        };
    };
}
