# Lunch Money for Claude Code: akutishevsky/lunchmoney-mcp, built from a
# pinned tag, loaded only by sessions started in `financeDir`. Imported by
# desktop.nix.
#
# The server needs its API token at startup, and the token lives only in
# 1Password, so each process that loads the server asks for Touch ID. Scoping
# it to one folder keeps that prompt out of every other session (the
# per-launch prompt is part of why kagi was cut; see TODO.md, 2026-09-03).
#
# Privacy: transaction-level data may be read in a session but must not
# persist. After any transaction or recurring-item tool runs, the session is
# marked, and from then on writes to agent memory and to the notes repo are
# denied. That mirrors Claude's Personal Finance, whose chats stay out of
# memory. Bash is checked by substring, so it is a guard, not a sandbox.
{
  config,
  lib,
  pkgs,
  ...
}:
let
  financeDir = "${config.home.homeDirectory}/Documents/finance";
  bin = "${config.home.profileDirectory}/bin";

  server = pkgs.buildNpmPackage (finalAttrs: {
    pname = "lunchmoney-mcp";
    version = "4.0.1";
    src = pkgs.fetchFromGitHub {
      owner = "akutishevsky";
      repo = "lunchmoney-mcp";
      tag = "mcpb-${finalAttrs.version}";
      hash = "sha256-wDN/dHoR3syfNTy8QHpzqSZDvwSgl8m5xEdd7W+HYeg=";
    };
    npmDepsHash = "sha256-gpt3ayaN94TKAA5kc/4Bj1d8+sQ+i4uVKNk/5ghwVa0=";
    meta.mainProgram = "lunchmoney-mcp";
  });

  lunchmoney-mcp = pkgs.writeShellApplication {
    name = "lunchmoney-mcp";
    runtimeInputs = [ pkgs._1password-cli ];
    # The "Lunch Money" API credential in the Personal vault, by ID: IDs survive
    # renames, and "Personal" is ambiguous to the CLI (the built-in Private
    # vault shares the name). The Private vault's "Lunch Money" is the web
    # login, not this token.
    text = ''
      LUNCHMONEY_API_TOKEN=$(op read --no-newline "op://d2kparnm4436vrbora6wnty6pm/5ocgbbek4giyja3ogukbqwl54e/credential")
      export LUNCHMONEY_API_TOKEN
      # attach_file_to_transaction reads any path it is given unless confined.
      export LUNCHMONEY_ATTACHMENTS_DIR=${lib.escapeShellArg financeDir}
      exec ${lib.getExe server} "$@"
    '';
  };

  # Hook command: `taint` marks the session (PostToolUse); `check` denies a
  # memory or notes write from a marked session (PreToolUse).
  lunchmoney-guard = pkgs.writeShellApplication {
    name = "lunchmoney-guard";
    runtimeInputs = [ pkgs.jq ];
    text = ''
      input=$(cat)
      marks="''${TMPDIR:-/tmp}/claude-lunchmoney-taint"
      mark="$marks/$(jq -r .session_id <<<"$input")"
      case "$1" in
        taint) mkdir -p "$marks" && touch "$mark" ;;
        check)
          [[ -e $mark ]] || exit 0
          target=$(jq -r '.tool_input | .file_path // .notebook_path // .command // ""' <<<"$input")
          case "$target" in
            */memory/* | *agent-memory* | *MEMORY.md* | *Documents/notes* | *\$NOTES*)
              jq -n '{hookSpecificOutput: {
                hookEventName: "PreToolUse",
                permissionDecision: "deny",
                permissionDecisionReason: "This session has read Lunch Money transaction data, so it may not write to agent memory or notes."
              }}'
              ;;
          esac
          ;;
      esac
    '';
  };

  mcpConfig.mcpServers.lunchmoney.command = "${bin}/lunchmoney-mcp";

  tool = name: "mcp__lunchmoney__${name}";
  guard = verb: {
    type = "command";
    command = "${bin}/lunchmoney-guard ${verb}";
    timeout = 5;
  };
  settings = {
    enabledMcpjsonServers = [ "lunchmoney" ];
    permissions = {
      allow = [ (tool "get_*") ];
      ask = map tool [
        "delete_*"
        "remove_budget"
        "update_transactions_bulk"
        "update_account_settings"
        "update_user_settings"
        "update_user_account_settings"
      ];
    };
    hooks = {
      PostToolUse = [
        {
          matcher = "mcp__lunchmoney__.*(transaction|recurring).*";
          hooks = [ (guard "taint") ];
        }
      ];
      PreToolUse = [
        {
          matcher = "Write|Edit|MultiEdit|NotebookEdit|Bash";
          hooks = [ (guard "check") ];
        }
      ];
    };
  };

  # Written as plain files, not home.file links: ~/Documents syncs to iCloud,
  # which does not carry symlinks into the nix store.
  files = {
    ".mcp.json" = pkgs.writeText "lunchmoney-mcp.json" (builtins.toJSON mcpConfig);
    ".claude/settings.json" = pkgs.writeText "lunchmoney-settings.json" (builtins.toJSON settings);
  };
in
{
  home.packages = [
    lunchmoney-mcp
    lunchmoney-guard
  ];

  home.activation.lunchmoneyFinanceDir = lib.hm.dag.entryAfter [ "writeBoundary" ] (
    lib.concatStrings (
      lib.mapAttrsToList (path: src: ''
        target=${lib.escapeShellArg "${financeDir}/${path}"}
        if ! cmp -s ${src} "$target"; then
          run install -Dm644 ${src} "$target"
        fi
      '') files
    )
  );
}
