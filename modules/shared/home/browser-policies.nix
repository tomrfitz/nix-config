# Shared policies for the Firefox-family browsers home-manager configures: Zen
# everywhere and base Firefox on the Linux desktop. They are live on darwin too:
# home-manager writes them to macOS defaults (EnterprisePoliciesEnabled), which
# the brew cask reads — verified with `defaults read app.zen-browser.zen`.
let
  amo = slug: {
    installation_mode = "normal_installed";
    install_url = "https://addons.mozilla.org/firefox/downloads/latest/${slug}/latest.xpi";
  };
  # Uninstalls the extension on every host and keeps Sync from restoring it.
  blocked = {
    installation_mode = "blocked";
  };
in
{
  sharedPolicies = {
    DisableTelemetry = true;
    # nix-wrapped (Linux) builds cannot self-update — leaving updates on just
    # produces failed-update prompts. zen.nix flips this back off on darwin.
    DisableAppUpdate = true;
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
      # Ads handled via Tampermonkey + video-swap-new userscript (install once
      # per profile, auto-updates): https://github.com/pixeltris/TwitchAdSolutions
      "frankerfacez@frankerfacez.com" = amo "frankerfacez";

      # reddit
      "jid1-xUfzOsOFlzSOXg@jetpack" = amo "reddit-enhancement-suite";
      "{4c421bb7-c1de-4dc6-80c7-ce8625e34d24}" = amo "load-reddit-images-directly";

      # twitter
      "{5cce4ab5-3d47-41b9-af5e-8203eea05245}" = amo "control-panel-for-twitter";

      # steam / gaming
      "firefox-extension@steamdb.info" = amo "steam-database";
      "{1be309c5-3e4f-4b99-927d-bb500eb4fa88}" = amo "augmented-steam";
      "{2b6c25c8-0c7e-4692-957f-c4ae6af0c34b}" = amo "improve-crunchyroll";

      # productivity & tools
      "firefox@tampermonkey.net" = amo "tampermonkey";
      "clipper@obsidian.md" = amo "web-clipper-obsidian";
      "firefox@cardpointers.com" = amo "cardpointers-x";
      "{cb31ec5d-c49a-4e5a-b240-16c767444f62}" = amo "indie-wiki-buddy";
      "historia@eros.man" = amo "historia";
      "{799c0914-748b-41df-a25c-22d008f9e83f}" = amo "web-scrobbler";

      # dev tools
      "{7962ff4a-5985-4cf2-9777-4bb642ad05b8}" = amo "svg-gobbler";

      # media
      "open_in_iina_firefox@iina.io" = amo "open-in-iina-x";

      # monitoring
      "{ef87d84c-2127-493f-b952-5b4e744245bc}" = amo "aw-watcher-web";

      # external (non-AMO)
      "zotero@chnm.gmu.edu" = {
        installation_mode = "normal_installed";
        install_url = "https://download.zotero.org/connector/firefox/release/Zotero_Connector-5.0.195.xpi";
      };

      # retired (2026-11-10)
      "{ef32ca60-1728-4011-a585-4de439fe7ba7}" = blocked; # Better Twitter
      "sky-follower-bridge@ryo.kawamata" = blocked;
      "jesse@adhdjesse.com" = blocked; # SkyLink
      "audiocontextsuspender@h43z" = blocked;
      "sabre@simplify.jobs" = blocked;
      "@react-devtools" = blocked;
      "notes@mozilla.com" = blocked; # Notes by Firefox
      "{3c078156-979c-498b-8990-85f7987dd929}" = blocked; # Sidebery
      "ATBC@EasonWong" = blocked; # Adaptive Tab Bar Colour
      "{a1f01957-5419-4d40-9937-bdf7bba038b4}" = blocked; # Chameleon Dynamic Theme
    };
  };
}
