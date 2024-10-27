{ pkgs, lib, config, inputs, ... }:

{
  packages = with pkgs; [ hugo dart-sass ];

  processes.serve.exec = "serve";

  scripts = {
    clean.exec = ''
      rm -rf "$DEVENV_ROOT/public"
    '';
    build.exec = ''
      hugo --gc --minify --environment production
    '';
    serve.exec = ''
      hugo serve \
        --buildDrafts \
        --buildFuture \
        --noHTTPCache \
        --watch \
        --renderToMemory
    '';
  };
}
