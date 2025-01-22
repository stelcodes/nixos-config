import os
import socket
import errno
import subprocess
import string
import shlex
import argparse
import sys
import io
import selectors

parser = argparse.ArgumentParser(
    prog="mpv-unify",
    description="Play files within a single instance of mpv",
    epilog="Inspired by umpv script from mpv: https://github.com/mpv-player/mpv/blob/master/TOOLS/umpv",
)

parser.add_argument("-q", "--queue", action="store_true")
parser.add_argument("-f", "--focus", action="store_true")
parser.add_argument("files", nargs="+")

args = parser.parse_args()


def capture_subprocess_output(subprocess_args):
    # Start subprocess
    # bufsize = 1 means output is line buffered
    # universal_newlines = True is required for line buffering
    process = subprocess.Popen(
        subprocess_args,
        bufsize=1,
        stdout=subprocess.PIPE,
        stderr=subprocess.STDOUT,
        universal_newlines=True,
    )

    # Create callback function for process output
    buf = io.StringIO()

    def handle_output(stream, mask):
        # Because the process' output is line buffered, there's only ever one
        # line to read when this function is called
        line = stream.readline()
        buf.write(line)
        sys.stdout.write(line)

    # Register callback for an "available for read" event from subprocess' stdout stream
    selector = selectors.DefaultSelector()
    selector.register(process.stdout, selectors.EVENT_READ, handle_output)

    # Loop until subprocess is terminated
    while process.poll() is None:
        # Wait for events and handle them with their registered callbacks
        events = selector.select()
        for key, mask in events:
            callback = key.data
            callback(key.fileobj, mask)

    # Get process return code
    return_code = process.wait()
    selector.close()

    # Store buffered output
    output = buf.getvalue()
    buf.close()

    return (return_code, output)


# this is the same method mpv uses to decide this
def is_url(filename):
    parts = filename.split("://", 1)
    if len(parts) < 2:
        return False
    # protocol prefix has no special characters => it's an URL
    allowed_symbols = string.ascii_letters + string.digits + "_"
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
    raise ValueError(
        "Either XDG_RUNTIME_DIR or HOME environment variable needs to be set"
    )

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
        pass  # doesn't exist
    else:
        raise e

if sock:
    # Unhandled race condition: what if mpv is terminating right now?
    verb = "append-play" if args.queue else "replace"
    for f in files:
        # escape: \ \n "
        f = f.replace("\\", "\\\\").replace('"', '\\"').replace("\n", "\\n")
        f = '"' + f + '"'
        sock.send(("raw loadfile " + f + " " + verb + "\n").encode("utf-8"))
else:
    # Let mpv recreate socket if it doesn't already exist.
    opts = shlex.split(os.getenv("MPV") or "@mpv@")
    if args.focus:
        opts.extend(["--focus-on=all"])
    else:
        opts.extend(["--focus-on=never"])
    opts.extend(
        ["--no-terminal", "--force-window", "--input-ipc-server=" + socket_path, "--"]
    )
    opts.extend(files)

    # Popen instead of check_call to start child process and exit immediately
    # stdout and stderr are sent to /dev/null so it won't print to shell env
    print(" ".join(opts))
    return_code, output = capture_subprocess_output(opts)
    exit(return_code)
