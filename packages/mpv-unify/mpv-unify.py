#!/usr/bin/env nix-shell
#!nix-shell -i python3

import os
import socket
import errno
import subprocess
import string
import shlex
import argparse

parser = argparse.ArgumentParser(
    prog='mpv-unify',
    description='Play files within a single instance of mpv',
    epilog='Inspired by umpv script from mpv: https://github.com/mpv-player/mpv/blob/master/TOOLS/umpv')

parser.add_argument('-a', '--append', action='store_true')
parser.add_argument('-f', '--focus', action='store_true')
parser.add_argument('files', nargs='+')

args = parser.parse_args()

print(args)

# this is the same method mpv uses to decide this
def is_url(filename):
    parts = filename.split("://", 1)
    if len(parts) < 2:
        return False
    # protocol prefix has no special characters => it's an URL
    allowed_symbols = string.ascii_letters + string.digits + '_'
    prefix = parts[0]
    return all(map(lambda c: c in allowed_symbols, prefix))

# make them absolute; also makes them safe against interpretation as options
def make_abs(filename):
    if not is_url(filename):
        return os.path.abspath(filename)
    return filename
files = (make_abs(f) for f in args.files)

socket_dir = os.getenv("XDG_RUNTIME_DIR") or os.getenv("HOME")

if not socket_dir:
    raise ValueError("Either XDG_RUNTIME_DIR or HOME environment variable needs to be set")

socket_path = os.path.join(socket_dir, ".mpv_unify_socket")

sock = None
try:
    sock = socket.socket(socket.AF_UNIX)
    sock.connect(socket_path)
except socket.error as e:
    if e.errno == errno.ECONNREFUSED:
        sock = None
        pass  # abandoned socket
    elif e.errno == errno.ENOENT:
        sock = None
        pass # doesn't exist
    else:
        raise e

if sock:
    # Unhandled race condition: what if mpv is terminating right now?
    verb = "append-play" if args.append else "replace"
    for f in files:
        # escape: \ \n "
        f = f.replace("\\", "\\\\").replace("\"", "\\\"").replace("\n", "\\n")
        f = "\"" + f + "\""
        sock.send(("raw loadfile " + f + " " + verb + "\n").encode("utf-8"))
else:
    # Let mpv recreate socket if it doesn't already exist.
    opts = shlex.split(os.getenv("MPV") or "mpv")
    if args.focus:
        opts.extend(["--focus-on-open"])
    else:
        opts.extend(["--no-focus-on-open"])
    opts.extend(["--no-terminal", "--force-window", "--input-ipc-server=" + socket_path,
                 "--"])
    opts.extend(files)

    # Popen instead of check_call to start child process and exit immediately
    # stdout and stderr are sent to /dev/null so it won't print to shell env
    subprocess.Popen(opts, stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
