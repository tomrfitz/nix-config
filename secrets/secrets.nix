# This file is read by the agenix CLI only -- it is NOT imported into
# the system configuration. It maps public keys to .age files so the
# CLI knows which recipients to encrypt each secret for.
let
  # User key (passphrase-less, dedicated to agenix decryption)
  tomrfitz = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHKuRWzPPSkXqXmShtH4IByClSRZYJFcQSuxq92RTYqq";

  # Host keys (one per machine that needs to decrypt at activation time)
  darwin = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIETQZ9USSILxRxfbEo4KvX7glcbg+JeUYnjITij3BJvs";
  # nixos = "ssh-ed25519 AAAA...";  # add when a NixOS host exists

  allKeys = [
    tomrfitz
    darwin
  ];
in
{
  "test-secret.age".publicKeys = allKeys;
}
