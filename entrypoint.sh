#!/bin/bash

# Remove apache2 PID file if it exists
rm -f /var/run/apache2/apache2.pid

# Execute the command provided as arguments to this script (e.g., apache2-foreground)
exec "$@"