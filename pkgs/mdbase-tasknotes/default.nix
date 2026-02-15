{
  lib,
  buildNpmPackage,
  fetchurl,
}:
buildNpmPackage rec {
  pname = "mdbase-tasknotes";
  version = "0.1.0";

  src = fetchurl {
    url = "https://registry.npmjs.org/${pname}/-/${pname}-${version}.tgz";
    hash = "sha256-nvGbiyAf5+JOalgf/mMNEq+3N51PbeadMFeK49sFRjk=";
  };

  sourceRoot = "package";

  npmDepsHash = "sha256-BZJZWYUQ9tTvnD0cm4KTKeQxZtWY8M3ZH6goifk8ZxQ=";

  postPatch = ''
    cp ${./package-lock.json} package-lock.json
  '';

  # Already pre-built — dist/cli.js ships in the tarball
  dontNpmBuild = true;

  meta = {
    description = "Standalone CLI for managing markdown tasks via mdbase";
    homepage = "https://github.com/callumalpass/mdbase-tasknotes";
    license = lib.licenses.mit;
    mainProgram = "mtn";
  };
}
