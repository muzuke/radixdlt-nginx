#!/bin/sh

set -e

exec wget -qO- --no-check-certificate  http://$HOSTNAME:9195/status >/dev/null
