# Howdy setup — remaining on-device steps

Config changes applied:
- Stable by-path device (`pci-0000:00:14.0-usb-0:6:1.2-video-index0`)
- IR native resolution forced to 340x340 (fixes cropping at 640x480)
- polkit-1 PAM service added (for 1Password system auth)
- polkit-127 camera sandbox workaround applied (nixpkgs#486044)

## Steps (run on trfnix after rebuild)

1. `nh os switch ~/nix-config`
2. `sudo linux-enable-ir-emitter configure`
3. `sudo howdy test` — verify camera feed is correct (340x340, no cropping)
4. `sudo howdy add` — enroll face model
5. Test: `sudo echo hi`
6. Test: lock screen with swaylock, unlock with face
7. Test: trigger 1Password system auth (unlock vault)

If `howdy test` still shows cropping, try the other resolution:
```
# In modules/nixos/system/default.nix, change to:
frame_width = 640;
frame_height = 480;
```

Delete this file when done.
