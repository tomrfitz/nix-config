# Shared browser policies for Firefox-based browsers (Firefox, Floorp, Zen)
let
  amo = slug: {
    installation_mode = "normal_installed";
    install_url = "https://addons.mozilla.org/firefox/downloads/latest/${slug}/latest.xpi";
  };
in
{
  inherit amo;

  sharedPolicies = {
    DisableTelemetry = true;
    DisableFirefoxStudies = true;
    DisablePocket = true;
    DontCheckDefaultBrowser = true;
    NoDefaultBookmarks = true;
    OfferToSaveLogins = false;
    PasswordManagerEnabled = false;

    ExtensionSettings = {
      # privacy & security
      "uBlock0@raymondhill.net" = amo "ublock-origin";
      "addon@darkreader.org" = amo "darkreader";
      "skipredirect@sblask" = amo "skip-redirect";
      "gdpr@cavi.au.dk" = amo "consent-o-matic";
      "@contain-facebook" = amo "facebook-container";
      "@testpilot-containers" = amo "multi-account-containers";

      # passwords & auth
      "{d634138d-c276-4fc8-924b-40a0ea21d284}" = amo "1password-x-password-manager";
      "{fdacee2c-bab4-490d-bc4b-ecdd03d5d68a}" = amo "nos2x-fox";

      # youtube
      "sponsorBlocker@ajay.app" = amo "sponsorblock";
      "deArrow@ajay.app" = amo "dearrow";
      "{3c6bf0cc-3ae2-42fb-9993-0d33104fdcaf}" = amo "youtube-addon";

      # twitch
      "firefox@betterttv.net" = amo "betterttv";
      "frankerfacez@frankerfacez.com" = amo "frankerfacez";
      "{76ef94a4-e3d0-4c6f-961a-d38a429a332b}" = amo "ttv-lol-pro";
      "moz-addon-prod@7tv.app" = {
        installation_mode = "normal_installed";
        install_url = "https://extension.7tv.gg/v3.1.13/ext.xpi";
      };

      # reddit
      "jid1-xUfzOsOFlzSOXg@jetpack" = amo "reddit-enhancement-suite";
      "{4c421bb7-c1de-4dc6-80c7-ce8625e34d24}" = amo "load-reddit-images-directly";

      # twitter / bluesky
      "{ef32ca60-1728-4011-a585-4de439fe7ba7}" = amo "better-twitter-extension";
      "{5cce4ab5-3d47-41b9-af5e-8203eea05245}" = amo "control-panel-for-twitter";
      "sky-follower-bridge@ryo.kawamata" = amo "sky-follower-bridge";
      "jesse@adhdjesse.com" = amo "skylink-bluesky-did-detector";

      # steam / gaming
      "firefox-extension@steamdb.info" = amo "steam-database";
      "{1be309c5-3e4f-4b99-927d-bb500eb4fa88}" = amo "augmented-steam";
      "{2b6c25c8-0c7e-4692-957f-c4ae6af0c34b}" = amo "improve-crunchyroll";

      # productivity & tools
      "firefox@tampermonkey.net" = amo "tampermonkey";
      "clipper@obsidian.md" = amo "web-clipper-obsidian";
      "notes@mozilla.com" = amo "notes-by-firefox";
      "sabre@simplify.jobs" = amo "simplify-jobs";
      "{cb31ec5d-c49a-4e5a-b240-16c767444f62}" = amo "indie-wiki-buddy";
      "historia@eros.man" = amo "historia";
      "{799c0914-748b-41df-a25c-22d008f9e83f}" = amo "web-scrobbler";

      # browser UI
      "{3c078156-979c-498b-8990-85f7987dd929}" = amo "sidebery";
      "ATBC@EasonWong" = amo "adaptive-tab-bar-colour";
      "{a1f01957-5419-4d40-9937-bdf7bba038b4}" = amo "chameleon-dynamic-theme-fixed";

      # dev tools
      "@react-devtools" = amo "react-devtools";
      "{7962ff4a-5985-4cf2-9777-4bb642ad05b8}" = amo "svg-gobbler";

      # media
      "open_in_iina_firefox@iina.io" = amo "open-in-iina-x";
      "audiocontextsuspender@h43z" = amo "audiocontext-suspender";

      # monitoring
      "{ef87d84c-2127-493f-b952-5b4e744245bc}" = amo "aw-watcher-web";

      # external (non-AMO)
      "zotero@chnm.gmu.edu" = {
        installation_mode = "normal_installed";
        install_url = "https://download.zotero.org/connector/firefox/release/Zotero_Connector-5.0.195.xpi";
      };
    };
  };
}
