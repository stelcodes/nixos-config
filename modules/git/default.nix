{ pkgs, ... }: {
  config = {
    environment.etc.gitconfig.text = ''
      [init]
        defaultBranch = "main"
      [merge]
        ff = "only"
      [user]
        email = "stel@stel.codes"
        name = "Stel Abrego"
      [core]
        excludesFile = /etc/gitignore
    '';
    environment.etc.gitignore.text = ''
      *Session.vim
      *.DS_Store
      *.swp
      *.direnv
      /direnv
      /local
      /node_modules
      *.jar
    '';
  };
}
