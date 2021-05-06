#!/bin/sh

set -e

exec wget -qO- --no-check-certificate  https://$HOSTNAME:9195/status >/dev/null
