# Howdy recovery steps

Config fix already applied: `services.howdy.control = "sufficient"` in
`modules/nixos/system/default.nix`. Reboot into a previous generation to
regain sudo, then:

1. `nh os switch ~/nix-config`
2. `sudo linux-enable-ir-emitter configure`
3. `sudo howdy add`
4. Test: `sudo echo hi`

Delete this file when done.
