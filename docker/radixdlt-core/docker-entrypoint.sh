#!/bin/sh

set -e

# Loosing entropy requirements to avoid blocking based on the the /dev/urandom manpage: https://linux.die.net/man/4/urandom
# ... "as a general rule, /dev/urandom should be used for everything except long-lived GPG/SSL/SSH keys" ...
find /usr/lib/jvm -type f -name java.security | xargs sed -i "s#^\s*securerandom.source=file:.*#securerandom.source=file:${CORE_SECURE_RANDOM_SOURCE:-/dev/urandom}#g"

# apply templating
cat >./etc/default.config <<EOF
api.url=/api
core.modules=assets,atoms,transactions
cp.port=8080
network.discovery.allow_tls_bypass=${CORE_NETWORK_ALLOW_TLS_BYPASS:-0}
network.discovery.urls=$CORE_NETWORK_DISCOVERY_URLS
network.seeds=$CORE_NETWORK_SEEDS
ntp=true
ntp.pool=pool.ntp.org
universe=$CORE_UNIVERSE
universe.lurking=${CORE_UNIVERSE_LURKING:-0}
universe.witness=${CORE_UNIVERSE_WITNESS:-0}
universe.witnesses=$CORE_UNIVERSE_WITNESSES
node.key.path=./etc/node.key
shards.range=${CORE_SHARD_RANGE:-17592186044416}
# NOTE: keep this disabled on a public network otherwise your node will get DoS attacked
spamathon.enabled=${CORE_SPAMATHON_ENABLED:-false}
EOF

# Configure logger
cat >./logger.config <<EOF
# Use 30 for no debug, 31 to include debug, 0 for no logging
logger.atoms.level=${CORE_LOGGER_ATOMS_LEVEL:-30}
logger.general.level=${CORE_LOGGER_GENERAL_LEVEL:-30}
logger.network.level=${CORE_LOGGER_NETWORK_LEVEL:-30}
logger.messaging.level=${CORE_LOGGER_MESSAGING_LEVEL:-30}
logger.discovery.level=${CORE_LOGGER_DISCOVERY_LEVEL:-30}
logger.RTP.level=${CORE_LOGGER_RTP_LEVEL:-0}
EOF

# make sure that the data partition has correct owner
#chown -R radixdlt:radixdlt .

# wipe DB env
if [ "$WIPE_LEDGER" = yes ]; then
    rm -rf RADIXDB/*
fi

if [ "$WIPE_NODE_KEY" = yes ]; then
    rm -f ./etc/node.key
fi

# leave 2GB for the the system - alloc the rest for the java process
max_mb=$(free -m | awk '$1 == "Mem:" { print $2}')
if [ $max_mb -gt 6144 ]; then
    export JAVA_OPTS="-Xmx$(($max_mb - 2048))m $JAVA_OPTS"
elif [ $max_mb -gt 4096 ]; then
    export JAVA_OPTS="-Xmx$(($max_mb - 1536))m $JAVA_OPTS"
elif [ $max_mb -gt 3072 ]; then
    export JAVA_OPTS="-Xmx$(($max_mb - 512))m $JAVA_OPTS"
else # JVM need at least 3GB Heap - 2GB will run with the occasional OutOfMemoryException
    export JAVA_OPTS="-Xmx2048m $JAVA_OPTS"
fi

# load iptables
# TODO: Need to tweak and test this some more before we can enable it in a public network.
if [ "$ENABLE_IPTABLES_RULES" = yes ]; then
    /sbin/iptables-restore < /etc/iptables/iptables.rules
fi

exec /sbin/su-exec radix:radix "$@"
