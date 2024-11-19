{ writeShellApplication }:
writeShellApplication {
  name = "tmux-startup";
  # Don't put tmux in runtimeInputs because that PATH is exported to every tmux shell
  runtimeInputs = [ ];
  text = builtins.readFile ./tmux-startup.sh;
}
