{
  config,
  pkgs,
  lib,
  ...
}:
{
  # ── Helix ──────────────────────────────────────────────────────────────
  programs.helix = {
    enable = true;
    settings = {
      theme = "flexoki-dark";
    };
    themes = {
      flexoki-dark = lib.importTOML ../../config/helix-flexoki-dark.toml;
      flexoki-light = lib.importTOML ../../config/helix-flexoki-light.toml;
    };
  };

  # ── Neovim ─────────────────────────────────────────────────────────────
  programs.neovim = {
    enable = true;
    defaultEditor = false;
    viAlias = true;
    vimAlias = true;
    initLua = ''
      vim.opt.number = true
      vim.opt.relativenumber = true
      vim.opt.expandtab = true
      vim.opt.shiftwidth = 2
      vim.opt.tabstop = 2
      vim.opt.smartindent = true
      vim.opt.termguicolors = true
      vim.opt.signcolumn = "yes"
      vim.opt.clipboard = "unnamedplus"
      vim.opt.ignorecase = true
      vim.opt.smartcase = true
    '';
  };

  programs.vscode.enable = true;
}
