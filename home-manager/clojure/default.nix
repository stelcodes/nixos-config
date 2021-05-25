pkgs: {
  home = {
    packages = [ pkgs.clojure pkgs.babashka pkgs.clj-kondo ];
    # I'm having a weird bug where clj -X:new gives an error about :exec-fn not being set even though it's set...
    # So I'm trying to put the deps.edn in the .config directory as well as the .clojure directory
    # I don't think this helped I had to use clj -X:new:clj-new/create
    file = { ".clojure/deps.edn".source = /home/stel/config/misc/deps.edn; };
  };
}
