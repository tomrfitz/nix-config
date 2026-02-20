# This file is read by the agenix CLI only -- it is NOT imported into
# the system configuration. It maps public keys to .age files so the
# CLI knows which recipients to encrypt each secret for.
let
  # User key (passphrase-less, dedicated to agenix decryption)
  tomrfitz = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHKuRWzPPSkXqXmShtH4IByClSRZYJFcQSuxq92RTYqq";

  # Host keys (one per machine that needs to decrypt at activation time)
  trfmbp = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIETQZ9USSILxRxfbEo4KvX7glcbg+JeUYnjITij3BJvs";
  # nixos = "ssh-ed25519 AAAA...";  # add when a NixOS host exists

  trfnix = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIC1Aw5I9x/nidakM8nUSsS3i3o/ip9z+5dk9OcFeo3d0";

  allKeys = [
    tomrfitz
    trfmbp
    trfnix
  ];
in
{
  "test-secret.age".publicKeys = allKeys;
}
