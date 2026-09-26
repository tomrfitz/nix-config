# Zotero — the app (nixpkgs on Linux; brew cask on darwin, where nixpkgs'
# firefox-esr build fails on aarch64-darwin) and 54yyyu/zotero-mcp, which
# gives agents the library as an MCP server (`zotero-mcp serve`) and a CLI
# (`zotero-cli`). Imported by desktop.nix: local mode needs Zotero running on
# the same host.
{
  config,
  lib,
  pkgs,
  ...
}:
let
  # zotero-mcp-server is not in nixpkgs, and packaging it would mean a newer
  # pyzotero and an unpackaged Rust pdf-inspector, chasing releases that land
  # about twice a week. uvx resolves the latest release from PyPI at launch
  # instead (its cache serves it offline), on nix's Python. The [pdf] extra
  # adds page images, layout and outlines; [semantic] would pull in torch.
  uvxZotero =
    bin:
    pkgs.writeShellApplication {
      name = bin;
      text = ''
        export UV_PYTHON=${lib.getExe pkgs.python3} UV_PYTHON_DOWNLOADS=never
        exec ${lib.getExe' pkgs.uv "uvx"} --from 'zotero-mcp-server[pdf]@latest' ${bin} "$@"
      '';
    };
  zotero-mcp = uvxZotero "zotero-mcp";

  server = {
    args = [ "serve" ];
    env = {
      # Reads come straight from zotero.sqlite; writes go to the running
      # Zotero once `zotero-mcp authorize-local` has been allowed there. The
      # server keeps that key in ~/.config/zotero-mcp/config.json, which it
      # writes itself, so home-manager leaves the file alone.
      ZOTERO_LOCAL = "true";
      # Core tools plus page geometry (for area annotations). The default
      # profile also carries `libraries` and `search-admin`, which serve group
      # libraries and the semantic index; neither exists here.
      ZOTERO_MCP_TOOLSETS = "pdf-geometry";
    };
  };
in
{
  home.packages = [
    zotero-mcp
    (uvxZotero "zotero-cli")
  ]
  ++ lib.optionals (!pkgs.stdenv.hostPlatform.isDarwin) [ pkgs.zotero ];

  programs.mcp = {
    enable = true;
    servers.zotero = server // {
      command = lib.getExe zotero-mcp;
    };
  };

  # The Claude desktop app reads local MCP servers from a config file it also
  # writes its own preferences to, so home-manager merges this one key into
  # it rather than owning the file. The command is the stable profile path,
  # so the key changes only with the server's args, not with each uv or
  # Python bump. The app reads the file at launch.
  home.activation.claudeDesktopZotero = lib.mkIf pkgs.stdenv.hostPlatform.isDarwin (
    lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      target="$HOME/Library/Application Support/Claude/claude_desktop_config.json"
      server=${
        lib.escapeShellArg (
          builtins.toJSON (
            server
            // {
              command = "${config.home.profileDirectory}/bin/zotero-mcp";
            }
          )
        )
      }
      if ! ${lib.getExe pkgs.jq} -e --argjson server "$server" '.mcpServers.zotero == $server' "$target" &>/dev/null; then
        merged=$(mktemp)
        if { cat "$target" 2>/dev/null || echo '{}'; } \
          | ${lib.getExe pkgs.jq} --argjson server "$server" '.mcpServers.zotero = $server' >"$merged"; then
          run install -Dm600 "$merged" "$target"
        else
          warnEcho "$target is not valid JSON; the Zotero MCP server was not added"
        fi
        rm -f "$merged"
      fi
    ''
  );
}
