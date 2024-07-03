{ config, pkgs, ... }:

{
    programs.firefox = {
        enable = true;
        package = pkgs.firefox-bin;
        profiles.default = {
            id = 0;
            name = "Default";
            settings = {
                "extensions.pocket.enabled" = false;
                "extensions.screenshots.disabled" = true;
                "browser.topsites.contile.enabled" = false;
                "browser.formfill.enable" = false;
                "browser.search.suggest.enabled" = false;
                "browser.search.suggest.enabled.private" = false;
                "browser.urlbar.suggest.searches" = false;
                "browser.urlbar.showSearchSuggestionsFirst" = false;
                "browser.newtabpage.activity-stream.feeds.section.topstories" = false;
                "browser.newtabpage.activity-stream.feeds.snippets" = false;
                "browser.newtabpage.activity-stream.section.highlights.includePocket" = false;
                "browser.newtabpage.activity-stream.section.highlights.includeBookmarks" = false;
                "browser.newtabpage.activity-stream.section.highlights.includeDownloads" = false;
                "browser.newtabpage.activity-stream.section.highlights.includeVisited" = false;
                "browser.newtabpage.activity-stream.showSponsored" = false;
                "browser.newtabpage.activity-stream.system.showSponsored" = false;
                "browser.newtabpage.activity-stream.showSponsoredTopSites" = false;
                "browser.ctrlTab.sortByRecentlyUsed" = true;
                "media.ffmpeg.vaapi.enabled" = true;
                "gfx.webrender.all" = true;
                "widget.dmabuf.force-enabled" = true;
                "media.hardware-video-decoding.force-enabled" = true;
                "widget.use-xdg-desktop-portal.file-picker" = 1;
                "dom.security.https_only_mode" = true;
                "dom.security.https_only_mode_ever_enabled" = true;
            };
            extensions = with pkgs.nur.repos.rycee.firefox-addons; [
                darkreader
                privacy-badger
                ublock-origin
                i-dont-care-about-cookies
                stylus
                plasma-integration
                youtube-shorts-block
            ];
        };
    };
}