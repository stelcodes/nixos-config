{ pkgs, ... }: {
  security.doas = {
    enable = true;
    extraRules = [{
      users = [ "stel" ];
      keepEnv = true;
      noPass = true;
    }];
  };
  security.sudo.enable = false;

  users.users.stel = {
    home = "/home/stel";
    isNormalUser = true;
    extraGroups = [ "wheel" "networkmanager" ];
    shell = pkgs.zsh;
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFl1QCu19AUDFaaZZAt4YtnxxdX+JDvDz5rdnBEfH/Bb stel@azul"
    ];
  };
  environment.systemPackages = with pkgs; [ zsh starship neovim git ];
}
