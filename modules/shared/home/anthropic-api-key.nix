# The Anthropic API key, for agent harnesses that call the Claude API directly
# (pi.nix, omp.nix). Max includes monthly Claude API credits, paid into the
# Console org linked to the plan; they cover the API and the Agent SDK, not
# Claude Code sessions or extra usage:
# https://platform.claude.com/docs/en/about-claude/api-credits-for-subscribers
#
# The key lives only in 1Password. Each harness runs `anthropic-api-key` from
# its own key-command setting and keeps the result in memory, so the key is
# never written to disk or exported. An exported ANTHROPIC_API_KEY would
# outrank the Max login in Claude Code and the Agent SDK (claude -p,
# pi-claude-bridge, Zed's and Emacs' Claude agents), which would then bill the
# credits or fail, and every agent's shell would inherit it:
# https://code.claude.com/docs/en/authentication#authentication-precedence
#
# 1Password asks for Touch ID once per terminal window; the authorization
# covers that window's processes (pi's subagents included) and lapses after 10
# idle minutes.
{ pkgs, ... }:
{
  home.packages = [
    (pkgs.writeShellApplication {
      name = "anthropic-api-key";
      runtimeInputs = [ pkgs._1password-cli ];
      text = ''exec op read --no-newline "op://Private/Anthropic API/credential"'';
    })
  ];
}
