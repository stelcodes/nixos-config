{ pkgs, ... }: {
  config = {
    environment.systemPackages = with pkgs; [ clojure jdk babashka clj-kondo ];
    programs.zsh.shellAliases = {
      "zprint" = "zprint '{:width 120}'";
      # Creating this alias because there's a weird bug with the clj command producing this error on nube1:
      # rlwrap: error: Cannot execute BINDIR/clojure: No such file or directory
      "clj" = "clojure";
    };
    # mkdir $HOME/.clojure && ln -s /etc/deps.edn $HOME/.clojure/deps.edn
    environment.etc."deps.edn".source = ./deps.edn;
  };
}
