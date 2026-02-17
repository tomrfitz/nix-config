{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (import ./browser-policies.nix) sharedPolicies;
  profile = config.programs.zen-browser.profiles.twilight;
in
{
  programs.zen-browser = {
    enable = true;
    package = lib.mkIf pkgs.stdenv.isDarwin null;
    policies = sharedPolicies;

    profiles.twilight = {
      id = 0;
      name = "default";
      path = "owckmgyi.Default (twilight)";
      isDefault = true;

      # ── Settings ─────────────────────────────────────────────────────
      settings = {
        # privacy
        "signon.rememberSignons" = false;
        "extensions.formautofill.addresses.enabled" = false;
        "extensions.formautofill.creditCards.enabled" = false;
        "network.dns.disablePrefetch" = true;
        "network.http.speculative-parallel-limit" = 0;
        "network.prefetch-next" = false;
        "privacy.globalprivacycontrol.enabled" = true;
        "privacy.bounceTrackingProtection.mode" = 1;

        # zen UI
        "zen.theme.use-system-colors" = true;
        "zen.theme.gradient.show-custom-colors" = true;
        "zen.theme.content-element-separation" = 0;
        "zen.view.compact.enable-at-startup" = true;
        "zen.welcome-screen.seen" = true;

        # navigation
        "browser.ctrlTab.sortByRecentlyUsed" = true;
        "browser.download.dir" = "${config.home.homeDirectory}/Downloads";
      };

      userChrome = builtins.readFile ../../../config/zen-userchrome.css;
      userContent = builtins.readFile ../../../config/zen-usercontent.css;

      # ── Search engines ─────────────────────────────────────────────
      search = {
        force = true;
        default = "Kagi";
        privateDefault = "Kagi";
        engines = {
          Kagi = {
            urls = [ { template = "https://kagi.com/search?q={searchTerms}"; } ];
            icon = "https://kagi.com/favicon.ico";
            definedAliases = [ "@k" ];
          };
          "Nix Packages" = {
            urls = [
              {
                template = "https://search.nixos.org/packages";
                params = [
                  {
                    name = "type";
                    value = "packages";
                  }
                  {
                    name = "channel";
                    value = "unstable";
                  }
                  {
                    name = "query";
                    value = "{searchTerms}";
                  }
                ];
              }
            ];
            icon = "${pkgs.nixos-icons}/share/icons/hicolor/scalable/apps/nix-snowflake.svg";
            definedAliases = [ "@np" ];
          };
          "Nix Options" = {
            urls = [
              {
                template = "https://search.nixos.org/options";
                params = [
                  {
                    name = "channel";
                    value = "unstable";
                  }
                  {
                    name = "query";
                    value = "{searchTerms}";
                  }
                ];
              }
            ];
            icon = "${pkgs.nixos-icons}/share/icons/hicolor/scalable/apps/nix-snowflake.svg";
            definedAliases = [ "@no" ];
          };
          "Home Manager" = {
            urls = [
              {
                template = "https://home-manager-options.extranix.com";
                params = [
                  {
                    name = "query";
                    value = "{searchTerms}";
                  }
                  {
                    name = "release";
                    value = "master";
                  }
                ];
              }
            ];
            definedAliases = [ "@hm" ];
          };
        };
      };

      # ── Containers ─────────────────────────────────────────────────
      containersForce = true;
      containers = {
        Personal = {
          id = 1;
          icon = "circle";
          color = "blue";
        };
        Work = {
          id = 2;
          icon = "briefcase";
          color = "orange";
        };
        Banking = {
          id = 3;
          icon = "dollar";
          color = "green";
        };
        Shopping = {
          id = 4;
          icon = "cart";
          color = "pink";
        };
        Facebook = {
          id = 8;
          icon = "fence";
          color = "toolbar";
        };
        Private = {
          id = 12;
          icon = "fingerprint";
          color = "purple";
        };
        "Private Container" = {
          id = 13;
          icon = "chill";
          color = "purple";
        };
      };

      # ── Spaces ─────────────────────────────────────────────────────
      spacesForce = true;
      spaces =
        let
          c = profile.containers;
        in
        {
          Home = {
            id = "3d8cb7d3-d268-4ddb-b998-912bfa854d6b";
            icon = "🏠";
            container = c.Personal.id;
            position = 1000;
          };
          Games = {
            id = "a4d06f1e-4d54-4a2f-866a-c4631f719cb2";
            icon = "🏓";
            container = c.Personal.id;
            position = 2000;
          };
          Plex = {
            id = "{85ff3e10-eb35-4687-9171-5967177dea1a}";
            icon = "🎥";
            container = c.Personal.id;
            position = 3000;
          };
          SmartCafe = {
            id = "6e5be3ce-62b9-40de-a189-9f5595c4fbd3";
            icon = "🍕";
            container = c.Work.id;
            position = 4000;
          };
        };

      # ── Pins ───────────────────────────────────────────────────────
      pinsForce = true;
      pins =
        let
          s = profile.spaces;
        in
        {
          # ── Home essentials ──
          Calendar = {
            id = "{546956cc-2d37-491a-81ee-e11d6bed941d}";
            url = "https://calendar.google.com/calendar/u/0/r";
            workspace = s.Home.id;
            container = profile.containers.Personal.id;
            position = 0;
            isEssential = true;
          };
          "Folding@home" = {
            id = "{10b26dc3-daec-4a78-81b5-5a65de407bce}";
            url = "https://v8-4.foldingathome.org/machines";
            workspace = s.Home.id;
            container = profile.containers.Personal.id;
            position = 1;
            isEssential = true;
          };
          ActivityWatch = {
            id = "{4693bca9-de9c-4307-a6ba-e92ddc1b319b}";
            url = "http://localhost:5600/#/activity/trfmbp/view/";
            workspace = s.Home.id;
            container = profile.containers.Personal.id;
            position = 2;
            isEssential = true;
          };

          # ── Home regular pins ──
          Bluesky = {
            id = "{97dbe9c2-e653-4172-b58e-fe9b05ecb03b}";
            url = "https://bsky.app/";
            workspace = s.Home.id;
            container = profile.containers.Personal.id;
            position = 3;
          };
          GitHub = {
            id = "{f7f06ed2-bd65-4c81-9697-669b4865e1d3}";
            url = "https://github.com/";
            workspace = s.Home.id;
            container = profile.containers.Personal.id;
            position = 4;
          };
          Reddit = {
            id = "{c7ffb244-086a-47ad-b9d8-f4282ecb5299}";
            url = "https://www.reddit.com/";
            workspace = s.Home.id;
            container = profile.containers.Personal.id;
            position = 5;
          };
          Twitch = {
            id = "{07e53f29-8af6-411a-9828-cf40c3721b58}";
            url = "https://www.twitch.tv/";
            workspace = s.Home.id;
            container = profile.containers.Personal.id;
            position = 6;
          };
          Twitter = {
            id = "{90c1d6fd-27a7-4cee-9715-132d77434cb5}";
            url = "https://x.com/";
            workspace = s.Home.id;
            container = profile.containers.Personal.id;
            position = 7;
          };
          YouTube = {
            id = "{9d8d2dc9-10b2-423d-8685-31998e299bbc}";
            url = "https://www.youtube.com/";
            workspace = s.Home.id;
            container = profile.containers.Personal.id;
            position = 8;
          };

          # ── Plex pins ──
          Plex = {
            id = "{88265c48-a298-4d0a-85f8-2d4cb17131b4}";
            url = "https://app.plex.tv/";
            workspace = s.Plex.id;
            position = 0;
          };
          Tautulli = {
            id = "{98441c65-8f0b-4e8c-850f-d74941e15f21}";
            url = "http://10.50.157.227:8181/";
            workspace = s.Plex.id;
            position = 1;
          };
          Sonarr = {
            id = "{01aa9f31-036a-4831-a955-f25bf107e9f6}";
            url = "http://10.50.157.227:8989/";
            workspace = s.Plex.id;
            position = 2;
          };
          Radarr = {
            id = "{ac5052b3-9b4d-4a2f-8d31-c7efc88e5d67}";
            url = "http://10.50.157.227:7878/";
            workspace = s.Plex.id;
            position = 3;
          };
          Lidarr = {
            id = "{32b376e2-3a62-4e24-bdf0-585631717e67}";
            url = "http://10.50.157.227:8686/";
            workspace = s.Plex.id;
            position = 4;
          };
          Readarr = {
            id = "{24875b71-2158-4334-afa5-0c1e9be92399}";
            url = "http://10.50.157.227:8787/";
            workspace = s.Plex.id;
            position = 5;
          };
          Bazarr = {
            id = "{2a42da54-8a2d-442a-8439-5eea547cbed2}";
            url = "http://10.50.157.227:6767/series";
            workspace = s.Plex.id;
            position = 6;
          };
          SABnzbd = {
            id = "{0dab148c-07e5-4863-8b7b-8f10258f4d4f}";
            url = "http://10.50.157.227:8080/";
            workspace = s.Plex.id;
            position = 8;
          };
          Calibre = {
            id = "{79fa38f7-7aca-4401-9cff-82d8f0d32024}";
            url = "http://10.50.186.183:7070/";
            workspace = s.Plex.id;
            position = 9;
          };

          # ── SmartCafe pins ──
          "Google Drive" = {
            id = "{9098f2eb-dc44-4e7a-b3ed-89f8262d4f64}";
            url = "https://drive.google.com/drive/u/0/my-drive";
            workspace = s.SmartCafe.id;
            container = profile.containers.Work.id;
            position = 0;
          };
          FreedomPay = {
            id = "{23de3202-592f-4b38-8502-598d77cb8929}";
            url = "https://enterprise.freedompay.com/SearchTransactions";
            workspace = s.SmartCafe.id;
            container = profile.containers.Work.id;
            position = 1;
          };
          Transactions = {
            id = "{0ebaefc0-fa9c-48ee-9aaa-c78cef1b1b18}";
            url = "https://docs.google.com/spreadsheets/d/1TCpyA6osZL5Zr4syIW6x-JfJ0qxkY5MtE0FxSEiC-VE/edit?gid=1248538141#gid=1248538141";
            workspace = s.SmartCafe.id;
            container = profile.containers.Work.id;
            position = 2;
          };

          # ── Games folders ──
          TFT = {
            id = "{e20a5134-d938-44ac-af50-5a4cce34b47c}";
            workspace = s.Games.id;
            container = profile.containers.Personal.id;
            position = 20;
            isGroup = true;
          };
          IC = {
            id = "{e5a492ab-b3b7-4571-8bb0-c9b19a501b33}";
            workspace = s.Games.id;
            container = profile.containers.Personal.id;
            position = 10;
            isGroup = true;
          };

          # ── Games regular pins ──
          "tactics.tools" = {
            id = "{364c8533-1d55-40f1-99bc-411ade98ac40}";
            url = "https://tactics.tools/player/na/chairr/428";
            workspace = s.Games.id;
            container = profile.containers.Personal.id;
            position = 0;
            folderParentId = "{e20a5134-d938-44ac-af50-5a4cce34b47c}";
          };
          TFTAcademy = {
            id = "{bd8a42f5-25bd-4619-a654-3d124ae82e3f}";
            url = "https://tftacademy.com/tierlist/comps";
            workspace = s.Games.id;
            container = profile.containers.Personal.id;
            position = 0;
            folderParentId = "{e20a5134-d938-44ac-af50-5a4cce34b47c}";
          };
          MetaTFT = {
            id = "{c313a302-5bb6-4460-aaa8-e446c1301b28}";
            url = "https://www.metatft.com/comps";
            workspace = s.Games.id;
            container = profile.containers.Personal.id;
            position = 0;
            folderParentId = "{e20a5134-d938-44ac-af50-5a4cce34b47c}";
          };
          "Melvor Wiki" = {
            id = "{62d3f515-c16e-437e-841f-0e4972e305de}";
            url = "https://wiki.melvoridle.com/w/What_to_level_first#Laid_Back";
            workspace = s.Games.id;
            container = profile.containers.Personal.id;
            position = 14;
          };
          "SWGOH Store" = {
            id = "{68ea95bb-acbe-4104-8937-51fd8e0c4995}";
            url = "https://store.galaxy-of-heroes.starwars.ea.com/";
            workspace = s.Games.id;
            container = profile.containers.Personal.id;
            position = 15;
          };
          "OP.GG" = {
            id = "{7f8bc5e5-e09a-4150-b995-b5a2222dbff3}";
            url = "https://op.gg/lol/summoners/NA/chairr-428";
            workspace = s.Games.id;
            container = profile.containers.Personal.id;
            position = 16;
          };
          "IC Stats" = {
            id = "{77949796-7f82-4536-ad84-34d65f3a04a9}";
            url = "https://ic.byteglow.com/stats";
            workspace = s.Games.id;
            container = profile.containers.Personal.id;
            position = 0;
            folderParentId = "{e5a492ab-b3b7-4571-8bb0-c9b19a501b33}";
          };
          "IC Spoilers" = {
            id = "{813d8e7b-c229-4e23-b8df-c5ed3b37cafe}";
            url = "https://emmotes.github.io/";
            workspace = s.Games.id;
            container = profile.containers.Personal.id;
            position = 0;
            folderParentId = "{e5a492ab-b3b7-4571-8bb0-c9b19a501b33}";
          };
          "IC Formations" = {
            id = "{37329734-b284-4835-91a7-e478fcdddcd3}";
            url = "https://docs.google.com/spreadsheets/d/1HDlLICXJvrs5jX609Cnud27UtNIoC-lPnIE3uLKJNe4/edit?gid=615343479#gid=615343479";
            workspace = s.Games.id;
            container = profile.containers.Personal.id;
            position = 0;
            folderParentId = "{e5a492ab-b3b7-4571-8bb0-c9b19a501b33}";
          };
          "IC Observe" = {
            id = "{e8c774fe-4978-44fc-8929-53742fbaa48e}";
            url = "https://docs.google.com/spreadsheets/d/1yZ6nKKcUPOQT9jsq6Gw5qoxSf_azWLUm3rEry28f9n8/edit?gid=949133861#gid=949133861";
            workspace = s.Games.id;
            container = profile.containers.Personal.id;
            position = 0;
            folderParentId = "{e5a492ab-b3b7-4571-8bb0-c9b19a501b33}";
          };
          "IC Kas" = {
            id = "{9427e497-bf94-4df9-92ae-61c0440782a8}";
            url = "https://docs.google.com/document/d/1IKIrkOHXYRpJ2-_HPQeE04Pqd_jIEUDhxGvMNMPGaTk/edit?tab=t.pxjgqjfm0743";
            workspace = s.Games.id;
            container = profile.containers.Personal.id;
            position = 0;
            folderParentId = "{e5a492ab-b3b7-4571-8bb0-c9b19a501b33}";
          };
          "IC Mehen" = {
            id = "{9276154f-da97-4600-abdd-731485182ddc}";
            url = "https://docs.google.com/document/d/1XG31IPkB4EuE06sETZBDVfX_OTC6mLlaa7YdNrMTR8Q/edit?tab=t.0#heading=h.6o78l5dqj4bn";
            workspace = s.Games.id;
            container = profile.containers.Personal.id;
            position = 0;
            folderParentId = "{e5a492ab-b3b7-4571-8bb0-c9b19a501b33}";
          };
        };

      # ── Keyboard shortcuts ─────────────────────────────────────────
      keyboardShortcutsVersion = 14;
      keyboardShortcuts = [
        {
          id = "zen-compact-mode-toggle";
          key = "s";
          modifiers.meta = true;
        }
        {
          id = "key_toggleReaderMode";
          disabled = true;
        }
      ];
    };
  };

  # Zen Browser requires write access to profiles.ini (to store install hashes
  # and lock flags). Home-manager deploys it as a read-only nix store symlink,
  # which causes Zen to loop on "Changes not saved". Replace the symlink with a
  # mutable copy after link generation so Zen can update it freely.
  home.activation.makeZenProfilesMutable = lib.hm.dag.entryAfter [ "linkGeneration" ] ''
    zenProfiles="${config.home.homeDirectory}/Library/Application Support/zen/profiles.ini"
    if [ -L "$zenProfiles" ]; then
      realPath=$(readlink "$zenProfiles")
      rm "$zenProfiles"
      cp "$realPath" "$zenProfiles"
      chmod u+w "$zenProfiles"
    fi
  '';
}
