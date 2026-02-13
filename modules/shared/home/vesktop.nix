{ ... }:
{
  programs.vesktop = {
    enable = true;

    settings = {
      discordBranch = "stable";
      minimizeToTray = true;
      arRPC = true;
      splashColor = "rgb(206, 205, 195)";
      splashPixelated = true;
      splashBackground = "rgb(16, 15, 15)";
    };

    vencord = {
      settings = {
        useQuickCss = true;
        themeLinks = [
          "@light https://raw.githubusercontent.com/kepano/flexoki/refs/heads/main/discord/flexoki-light.css"
          "@dark https://raw.githubusercontent.com/kepano/flexoki/refs/heads/main/discord/flexoki-dark.css"
        ];
        notifications = {
          timeout = 5000;
          position = "bottom-right";
          useNative = "not-focused";
          logLimit = 50;
        };
        plugins = {
          CommandsAPI.enabled = true;
          MemberListDecoratorsAPI.enabled = true;
          MessageAccessoriesAPI.enabled = true;
          MessageDecorationsAPI.enabled = true;
          MessageEventsAPI.enabled = true;
          UserSettingsAPI.enabled = true;
          BadgeAPI.enabled = true;
          NoTrack = { enabled = true; disableAnalytics = true; };
          Settings = { enabled = true; settingsLocation = "aboveNitro"; };
          DisableDeepLinks.enabled = true;
          SupportHelper.enabled = true;
          WebContextMenus.enabled = true;
          WebKeybinds.enabled = true;
          WebScreenShareFixes.enabled = true;
          CrashHandler.enabled = true;

          AlwaysExpandRoles.enabled = true;
          AnonymiseFileNames.enabled = true;
          AppleMusicRichPresence = {
            enabled = true;
            refreshInterval = 5;
            activityType = 2;
            enableTimestamps = true;
            enableButtons = true;
            nameString = "Apple Music";
            detailsString = "{name}";
            stateString = "{artist} · {album}";
            largeImageType = "Album";
            largeTextString = "{album}";
            smallImageType = "Artist";
            smallTextString = "{artist}";
          };
          BetterFolders = {
            enabled = true;
            sidebar = true;
            showFolderIcon = 1;
            sidebarAnim = true;
          };
          BetterGifAltText.enabled = true;
          CallTimer = { enabled = true; format = "stopwatch"; };
          ClearURLs.enabled = true;
          DontRoundMyTimestamps.enabled = true;
          FixSpotifyEmbeds.enabled = true;
          FixYoutubeEmbeds.enabled = true;
          ForceOwnerCrown.enabled = true;
          FriendsSince.enabled = true;
          MemberCount = { enabled = true; toolTip = true; };
          MentionAvatars = { enabled = true; showAtSymbol = true; };
          NewGuildSettings = {
            enabled = true;
            guild = true;
            messages = 2;
            everyone = true;
            role = true;
            highlights = true;
            events = true;
            showAllChannels = true;
          };
          OnePingPerDM = { enabled = true; channelToAffect = "both_dms"; };
          RoleColorEverywhere = {
            enabled = true;
            chatMentions = true;
            memberList = true;
            voiceUsers = true;
            reactorsList = true;
            pollResults = true;
          };
          TypingIndicator = {
            enabled = true;
            includeCurrentChannel = true;
            indicatorMode = 3;
          };
          TypingTweaks = {
            enabled = true;
            alternativeFormatting = true;
            showRoleColors = true;
            showAvatars = true;
          };
          UserVoiceShow = {
            enabled = true;
            showInUserProfileModal = true;
            showInMemberList = true;
            showInMessages = true;
          };
        };
      };

      extraQuickCss = ''
        :root {
          --background-code: 255, 252, 240;
        }

        code.inline {
          background-color: var(--backgroundprimary);
        }

        [class*="codeContainer_"] > [class*="scrollbarGhostHairline_"] {
          background-color: var(--backgroundprimary) ;
        }
      '';
    };
  };
}
