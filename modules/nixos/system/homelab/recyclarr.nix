{
  config,
  lib,
  ...
}:
let
  cfg = config.trf.homelab;
in
{
  config = lib.mkIf (cfg.enable && config.services.recyclarr.enable) {
    services.recyclarr = {
      schedule = "daily";

      # Recyclarr syncs guide-backed quality profiles and custom formats
      # from TRaSH Guides into Sonarr/Radarr.
      configuration = {
        sonarr.tv = {
          base_url = "http://127.0.0.1:8989";
          api_key._secret = "/etc/secrets/recyclarr/sonarr-api-key";
          include = [
            # Quality definition
            { template = "sonarr-quality-definition-series"; }
            # WEB-1080p profile + custom formats
            { template = "sonarr-v4-quality-profile-web-1080p"; }
            { template = "sonarr-v4-custom-formats-web-1080p"; }
            # WEB-2160p profile + custom formats
            { template = "sonarr-v4-quality-profile-web-2160p"; }
            { template = "sonarr-v4-custom-formats-web-2160p"; }
          ];
        };

        radarr.movies = {
          base_url = "http://127.0.0.1:7878";
          api_key._secret = "/etc/secrets/recyclarr/radarr-api-key";
          include = [
            # Quality definition
            { template = "radarr-quality-definition-movie"; }
            # HD Bluray + WEB profile + custom formats
            { template = "radarr-quality-profile-hd-bluray-web"; }
            { template = "radarr-custom-formats-hd-bluray-web"; }
            # UHD Bluray + WEB profile + custom formats
            { template = "radarr-quality-profile-uhd-bluray-web"; }
            { template = "radarr-custom-formats-uhd-bluray-web"; }
            # Remux + WEB 1080p profile + custom formats
            { template = "radarr-quality-profile-remux-web-1080p"; }
            { template = "radarr-custom-formats-remux-web-1080p"; }
            # Remux + WEB 2160p profile + custom formats
            { template = "radarr-quality-profile-remux-web-2160p"; }
            { template = "radarr-custom-formats-remux-web-2160p"; }
          ];
        };
      };
    };

  };
}
