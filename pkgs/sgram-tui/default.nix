{
  lib,
  fetchFromGitHub,
  rustPlatform,
  stdenv,
  alsa-lib,
  pkg-config,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "sgram-tui";
  version = "0.2.1";

  src = fetchFromGitHub {
    owner = "arian-shamaei";
    repo = "sgram-tui";
    tag = "v${finalAttrs.version}";
    hash = "sha256-zcPUtYtGz0nKD+jWXCLj7qZi7x4P+kk+2C//Pyn8wuo=";
  };

  cargoHash = lib.fakeHash;

  nativeBuildInputs = lib.optionals stdenv.isLinux [ pkg-config ];
  buildInputs = lib.optionals stdenv.isLinux [ alsa-lib ];

  meta = {
    description = "Terminal spectrogram viewer with mic/WAV input and tunable DSP";
    homepage = "https://github.com/arian-shamaei/sgram-tui";
    license = lib.licenses.mit;
    mainProgram = "sgram-tui";
  };
})
