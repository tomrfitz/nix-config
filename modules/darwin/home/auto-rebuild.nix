_: {
  launchd.agents.auto-rebuild = {
    enable = true;
    config = {
      Label = "com.tomrfitz.auto-rebuild";
      ProgramArguments = [
        "/run/current-system/sw/bin/nh"
        "darwin"
        "switch"
        "--refresh"
      ];
      EnvironmentVariables = {
        NH_FLAKE = "github:tomrfitz/nix-config/main";
        PATH = "/run/current-system/sw/bin:/nix/var/nix/profiles/default/bin:/usr/bin:/bin";
      };
      StartCalendarInterval = [
        {
          Hour = 6;
          Minute = 30;
        }
      ];
      StandardOutPath = "/tmp/auto-rebuild.log";
      StandardErrorPath = "/tmp/auto-rebuild.log";
    };
  };
}
