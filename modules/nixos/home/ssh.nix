{ ... }:
{
  programs.ssh.matchBlocks."*" = {
    extraOptions = {
      AddKeysToAgent = "yes";
      IdentityAgent = "~/.1password/agent.sock";
    };
  };
}
