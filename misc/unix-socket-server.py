#! /usr/bin/env nix-shell
#! nix-shell -i python -p python311

from socketserver import UnixStreamServer, StreamRequestHandler
import sys

class Handler(StreamRequestHandler):
    def handle(self):
        msg = self.rfile.readline().strip()
        if msg:
            print("Data Recieved from client is: {}".format(msg))
        else:
            return

if __name__ == "__main__":
    try:
        socket = sys.argv[1]
    except:
        raise Exception("Socket path argument is required")
    print("Starting unix socket server at path: " + socket)
    with UnixStreamServer(socket, Handler) as server:
        server.serve_forever()
