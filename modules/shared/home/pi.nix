# pi (earendil-works) coding agent — nixpkgs' pi-coding-agent through home-manager's
# programs.pi-coding-agent, plus the npm community packages and the repo-local resource
# bundle wired into pi's expected directories. Configured on every host.
#
# Models: `anthropic/*` runs on the Max plan's monthly API credits, with the key from
# 1Password (anthropic-api-key.nix); `claude-bridge/*` (pi-claude-bridge) runs Claude Code
# through the Agent SDK on the Max login and draws plan limits instead.
#
# Three integration paths, owning separate lanes:
#   - **npm community packages**: declared in settings.json `packages` (below). pi installs
#     any missing one at startup into ~/.pi/agent/npm/ and resolves it through its bundled
#     npm; `pi update --extensions` moves them to their latest releases. Lifecycle is pi's.
#   - **Repo-local resources** (author-owned skills and prompts) in
#     ../../../pi-resources/: exposed under ~/.pi/agent/ via out-of-store symlinks pointing
#     at the working tree. Pi's user-scope auto-discovery picks them up. Edits to files in
#     pi-resources/ take effect on the next pi restart with no rebuild needed; reverts are
#     `git checkout`. A rebuild is only required when the wiring itself changes (e.g. adding
#     a new top-level skill folder). Lifecycle is nix's.
#   - **Third-party skills** (mattpocock/skills): consumed via the `mattpocock-skills` flake
#     input — only the skills upstream promotes in its plugin manifest, each symlinked into
#     ~/.pi/agent/skills/mattpocock/<name>/ (its draft and deprecated dirs stay out, as the
#     upstream ADR intends). Updates land with the lock bump.
#
# settings.json and auth.json stay writable: pi writes runtime state into both (logins,
# the model you pick, `pi install`), and a read-only settings.json breaks `pi install` and
# re-shows the changelog every launch. So activation merges only the keys declared here
# into them (objects key by key, lists replaced); pi keeps the rest, and a `/model` pick
# lasts until the next switch. Global instructions (~/.pi/agent/AGENTS.md) come from the
# module's `context`, the same file the other agents get.
{
  config,
  lib,
  pkgs,
  mattpocock-skills,
  ...
}:
let
  # Community packages, kept in ~/.pi/agent/npm/.
  piPackages = [
    "pi-subagents" # Subagent orchestration — chains, parallel, builtin agents (scout/researcher/planner/worker/reviewer/oracle/...)
    "pi-web-access" # Web search + fetch + GitHub clone + PDF + YouTube; backs the researcher builtin
    "pi-lens" # Real-time LSP + formatters + auto-fix + secrets scan + read-before-edit guard on every write/edit
    "pi-intercom" # Direct session-to-session messaging; required for the contact_supervisor escalation tool in pi-subagents children
    "pi-hermes-memory" # Persistent memory across sessions with FTS5 search, auto-consolidation, and secret scanning (not on claude-bridge models, which drop pi's system prompt edits)
    "@juicesharp/rpiv-btw" # /btw side-conversation channel — ephemeral side questions without polluting the main session
    "pi-claude-bridge" # claude-bridge/* models: Claude Code via the Agent SDK on the Max login (plan limits, not API credits)
  ];

  settings = {
    defaultProvider = "anthropic";
    defaultModel = "claude-opus-5-5";
    defaultThinkingLevel = "high";
    enableInstallTelemetry = false;
    packages = map (p: "npm:${p}") piPackages;
    # Cheaper models for the roles that read a lot and decide little.
    subagents.agentOverrides = {
      researcher = {
        model = "anthropic/claude-sonnet-5-5";
        thinking = "medium";
      };
      reviewer = {
        model = "anthropic/claude-sonnet-5-5";
        thinking = "medium";
      };
      scout = {
        model = "anthropic/claude-haiku-5-5";
        thinking = "low";
      };
    };
  };

  # pi runs a `!command` key when the provider is first used and caches it for the
  # process lifetime: https://pi.dev/docs/latest/providers
  auth.anthropic = {
    type = "api_key";
    key = "!${config.home.profileDirectory}/bin/anthropic-api-key";
  };

  # Deep-merge `attrs` into ~/.pi/agent/<name>; write only on a change, mode 600 (auth.json
  # holds the other providers' logins).
  mergeInto =
    name: attrs:
    let
      own = pkgs.writeText "pi-${name}" (builtins.toJSON attrs);
      f = "${config.home.homeDirectory}/.pi/agent/${name}";
    in
    ''
      merged=$(mktemp)
      if [ -s "${f}" ]; then base="${f}"; else base=<(echo '{}'); fi
      if ${lib.getExe pkgs.jq} -s '.[0] * .[1]' "$base" ${own} > "$merged"; then
        cmp -s "$merged" "${f}" || run install -D -m 600 "$merged" "${f}"
      else
        echo "pi: could not merge the declared keys into ${f}" >&2
      fi
      rm -f "$merged"
    '';

  # Out-of-store symlinks pointing at the working tree. Edits flow through the symlink to the
  # repo and back — the working tree IS the declared state. If you relocate the repo, change
  # the `nix-config` segment here (or factor it out into a shared binding / env var).
  piRes = "${config.home.homeDirectory}/nix-config/pi-resources";
  link = path: config.lib.file.mkOutOfStoreSymlink "${piRes}/${path}";

  # Upstream's promoted skills, read from its plugin manifest so renames track.
  # One link farm, so ~/.pi/agent/skills/mattpocock stays a single symlink that
  # home-manager can swap (a directory of links there would collide with the
  # previous generation's link into the store).
  promoted = (lib.importJSON "${mattpocock-skills}/.claude-plugin/plugin.json").skills;
  promotedSkills = pkgs.linkFarm "mattpocock-skills" (
    map (p: {
      name = baseNameOf p;
      path = "${mattpocock-skills}/${lib.removePrefix "./" p}";
    }) promoted
  );
in
{
  programs.pi-coding-agent = {
    enable = true;
    context = ../../../config/agents.md;
    extraPackages = [ pkgs.nodejs ]; # `pi install npm:` needs npm on pi's PATH
  };

  home.activation.piSettings = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    ${mergeInto "settings.json" settings}
    ${mergeInto "auth.json" auth}
  '';

  home.file = {
    ".pi/agent/skills/org-notes".source = link "skills/org-notes";
    ".pi/agent/skills/mattpocock".source = promotedSkills;
    ".pi/agent/prompts/simplify.md".source = link "prompts/simplify.md";
    # Read-only is fine: the bridge writes this file only to dismiss its startup
    # notice, which never shows while both keys are set.
    ".pi/agent/claude-bridge.json".text = builtins.toJSON {
      provider.plan = "max";
      askClaude.enabled = false;
    };
  };
}
