---
name: nix-search
description: Search nixpkgs for a package
user-invocable: true
disable-model-invocation: true
---

# nix-search

Search nixpkgs for the package specified in the argument: run `nix search nixpkgs <arg>` (installable first, search regex as a separate argument — Lix errors on the `nixpkgs#<arg>` form) and present the results in a concise table showing package name, version, and description.

If no argument is provided, ask the user what package to search for.
