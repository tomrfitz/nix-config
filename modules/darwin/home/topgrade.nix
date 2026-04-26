_: {
  programs.topgrade.settings = {
    pre_commands = {
      "Flake Update + Darwin Rebuild" = ''
        # Warm up SSH multiplex so git pulls don't hang on first connect
        ssh -T git@github.com || true

        nh darwin switch --refresh
      '';
    };
    brew = {
      greedy_latest = true;
      greedy_auto_updates = true;
      autoremove = true;
      fetch_head = true;
    };
  };
}
