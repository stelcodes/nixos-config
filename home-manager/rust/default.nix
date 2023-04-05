pkgs: {
  home = {
    # Run this:
    # rustup toolchain install stable
    # cargo install <package>
    packages = [ pkgs.rustup ];
    sessionPath = [ "$HOME/.cargo/bin" ];
  };
}
