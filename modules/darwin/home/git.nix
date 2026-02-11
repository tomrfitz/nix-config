{ pkgs, ... }:
{
  programs.git.settings = {
    gpg.ssh.program = "/Applications/1Password.app/Contents/MacOS/op-ssh-sign";
    credential = {
      "https://github.com" = {
        helper = [
          ""
          "!${pkgs.gh}/bin/gh auth git-credential"
        ];
      };
      "https://gist.github.com" = {
        helper = [
          ""
          "!${pkgs.gh}/bin/gh auth git-credential"
        ];
      };
    };
  };
}
