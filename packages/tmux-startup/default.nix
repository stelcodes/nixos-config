{ tmux
, writeShellApplication
}:
writeShellApplication {
  name = "tmux-startup";
  runtimeInputs = [ tmux ];
  text = builtins.readFile ./tmux-startup.sh;
}
