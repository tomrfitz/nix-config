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
          api_key._secret = "/run/credentials/recyclarr.service/sonarr-api-key";

          quality_definition = {
            type = "series";
          };

          # Guide-backed profiles currently require `trash_id`.
          # Keep names in comments for readability.
          quality_profiles = [
            {
              # WEB-1080p
              trash_id = "72dae194fc92bf828f32cde7744e51a1";
              reset_unmatched_scores.enabled = true;
            }
            {
              # WEB-2160p
              trash_id = "d1498e7d189fbe6c7110ceaabb7473e6";
              reset_unmatched_scores.enabled = true;
            }
          ];
        };

        radarr.movies = {
          base_url = "http://127.0.0.1:7878";
          api_key._secret = "/run/credentials/recyclarr.service/radarr-api-key";

          quality_definition = {
            type = "movie";
          };

          quality_profiles = [
            {
              # HD Bluray + WEB
              trash_id = "d1d67249d3890e49bc12e275d989a7e9";
              reset_unmatched_scores.enabled = true;
            }
            {
              # UHD Bluray + WEB
              trash_id = "64fb5f9858489bdac2af690e27c8f42f";
              reset_unmatched_scores.enabled = true;
            }
            {
              # Remux + WEB 1080p
              trash_id = "9ca12ea80aa55ef916e3751f4b874151";
              reset_unmatched_scores.enabled = true;
            }
            {
              # Remux + WEB 2160p
              trash_id = "fd161a61e3ab826d3a22d53f935696dd";
              reset_unmatched_scores.enabled = true;
            }
          ];
        };
      };
    };

    # Host-local API key files (kept out of the nix store).
    systemd.services.recyclarr.serviceConfig.LoadCredential = [
      "sonarr-api-key:/etc/secrets/recyclarr/sonarr-api-key"
      "radarr-api-key:/etc/secrets/recyclarr/radarr-api-key"
    ];
  };
}
