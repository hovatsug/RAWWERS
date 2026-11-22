#!/usr/bin/env bash
# The client app against the test server. See run-against-server.sh.
exec "$(dirname "$0")/run-against-server.sh" client "$@"
