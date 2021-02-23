#!/usr/bin/env python
# coding: utf-8


import os
from SocketServer import ThreadingMixIn
from BaseHTTPServer import HTTPServer
from CGIHTTPServer import CGIHTTPRequestHandler
import threading
import cgitb
cgitb.enable()  # enable CGI error reporting


class ThreadedHTTPServer(ThreadingMixIn, HTTPServer):
    """Handle requests in a separate thread."""


web_dir = os.path.join(os.path.dirname(__file__))
os.chdir(web_dir)

server = ThreadedHTTPServer(('0.0.0.0', 8000), CGIHTTPRequestHandler)
server.serve_forever()
