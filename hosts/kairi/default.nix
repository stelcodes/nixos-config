{ ... }: {

  # build vm image:
  #   nixos-rebuild build-vm-with-bootloader --flake "$HOME/nixos-config#kairi"
  # test ssh:
  #   QEMU_NET_OPTS='hostfwd=tcp::2222-:22' <vm_start_script>
  #   ssh stel@localhost -p 2222
  # build droplet image:
  #   nix build .#nixosConfigurations.kairi.config.formats.do

  profile = {
    server = true;
    virtual = true;
  };

  system.stateVersion = "23.11";
}
