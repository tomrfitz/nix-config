# pi (earendil-works) coding agent — wires npm community packages and the repo-local resource
# bundle into pi's expected directories.
#
# Three integration paths, owning separate lanes:
#   - **npm community packages**: installed via `pi install npm:<pkg>` on activation. Pi tracks
#     them in its own settings.json registry and resolves them through its bundled npm. Lifecycle
#     is pi's (it updates them via its own commands).
#   - **Repo-local resources** (author-owned skills + prompts) in ../../../pi-resources/:
#     exposed under ~/.pi/agent/{skills,prompts}/ via out-of-store symlinks pointing at the
#     working tree. Pi's user-scope auto-discovery picks them up. Edits to files in
#     pi-resources/ take effect on the next pi restart with no rebuild needed; reverts are
#     `git checkout`. A rebuild is only required when the wiring itself changes (e.g. adding
#     a new top-level skill folder). Lifecycle is nix's.
#   - **Third-party skills** (mattpocock/skills): consumed via the `mattpocock-skills` flake
#     input, symlinked into ~/.pi/agent/skills/mattpocock/. Pi walks SKILL.md recursively so
#     the whole upstream catalog (engineering/, productivity/, etc.) is exposed. Updates land
#     via `nix flake update'; the lockfile pins the version.
#
# ~/.pi/agent/settings.json is left unmanaged (pi writes its own runtime state). Global
# instructions (~/.pi/agent/AGENTS.md) are wired with the other agents in default.nix.
#
# npm installs are guarded idempotently: skip if already in the registry, warn + retry next
# rebuild on failure, bounded by timeout.
#
# Darwin-only: pi is only used interactively on the daily driver, and this keeps npm/CLI steps
# out of the headless trfwsl rebuild pipeline.
{
  config,
  lib,
  pkgs,
  isDarwin,
  mattpocock-skills,
  ...
}:
let
  jq = lib.getExe pkgs.jq;
  timeout = "${pkgs.coreutils}/bin/timeout";
  piExe = "${pkgs.llm-agents.pi}/bin/pi";

  # Community packages installed into ~/.pi/agent/npm/ and tracked in settings.json.
  piPackages = [
    "pi-subagents" # Subagent orchestration — chains, parallel, builtin agents (scout/researcher/planner/worker/reviewer/oracle/...)
    "pi-web-access" # Web search + fetch + GitHub clone + PDF + YouTube; backs the researcher builtin
    "pi-lens" # Real-time LSP + formatters + auto-fix + secrets scan + read-before-edit guard on every write/edit
    "pi-intercom" # Direct session-to-session messaging; required for the contact_supervisor escalation tool in pi-subagents children
    "pi-hermes-memory" # Persistent memory across sessions with FTS5 search, auto-consolidation, and secret scanning
    "@juicesharp/rpiv-btw" # /btw side-conversation channel — ephemeral side questions without polluting the main session
  ];

  installPkg = pkg: ''
    if ! ${jq} -e '(.packages // []) | map(if type == "string" then . else (.source // "") end) | any(test("${pkg}"))' \
         "$HOME/.pi/agent/settings.json" >/dev/null 2>&1; then
      run env PATH="${pkgs.nodejs}/bin:$PATH" ${timeout} 180 ${piExe} install npm:${pkg} \
        || echo "pi: 'pi install ${pkg}' failed — will retry next rebuild" >&2
    fi
  '';

  # Out-of-store symlinks pointing at the working tree. Edits flow through the symlink to the
  # repo and back — the working tree IS the declared state. If you relocate the repo, change
  # the `nix-config` segment here (or factor it out into a shared binding / env var).
  piRes = "${config.home.homeDirectory}/nix-config/pi-resources";
  link = path: config.lib.file.mkOutOfStoreSymlink "${piRes}/${path}";
in
{
  home.activation = lib.mkIf isDarwin {
    installPiPackages = lib.hm.dag.entryAfter [ "writeBoundary" ] (
      lib.concatStringsSep "\n" (map installPkg piPackages)
    );
  };

  home.file = lib.mkIf isDarwin {
    ".pi/agent/skills/obsidian-vault".source = link "skills/obsidian-vault";
    # Third-party skills from the flake input — not vendored. Pi walks
    # SKILL.md recursively so the whole upstream tree is exposed.
    ".pi/agent/skills/mattpocock".source = "${mattpocock-skills}/skills";
    ".pi/agent/prompts/simplify.md".source = link "prompts/simplify.md";
  };
}
