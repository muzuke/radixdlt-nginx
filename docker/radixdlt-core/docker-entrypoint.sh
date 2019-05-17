#!/bin/sh

set -e

# Loosing entropy requirements to avoid blocking based on the the /dev/urandom manpage: https://linux.die.net/man/4/urandom
# ... "as a general rule, /dev/urandom should be used for everything except long-lived GPG/SSL/SSH keys" ...
find /usr/lib/jvm -type f -name java.security | xargs sed -i "s#^\s*securerandom.source=file:.*#securerandom.source=file:${CORE_SECURE_RANDOM_SOURCE:-/dev/urandom}#g"

set -x

# Prepare for 1M-TPS
apk add --no-cache --update curl

if [ ! -e ./etc/node.key ]; then
    SHARD_SEED=$(dd status=none if=/dev/urandom count=32 bs=1 | base64)
    SHARD_CFG=$(curl -sf "http://$CORE_EXPLORER_IP:8080/shard?seed=$SHARD_SEED")
    ANCHOR_POINT=$(echo $SHARD_CFG | awk '{print $1}')
    NODE_KEY_RANGE=$(echo $SHARD_CFG | awk '{print $2}')
    CHUNK_RANGE=$(echo $SHARD_CFG | awk '{print $3}')
    ./bin/generate_node_key "$ANCHOR_POINT" "$NODE_KEY_RANGE" ./etc/node.key
    chown radix:radix ./etc/node.key
fi

set +x

# apply templating
cat >./etc/default.config <<EOF
api.url=/api
core.modules=assets,atoms,transactions
cp.port=8080
network.discovery.allow_tls_bypass=${CORE_NETWORK_ALLOW_TLS_BYPASS:-0}
network.discovery.urls=$CORE_NETWORK_DISCOVERY_URLS
network.seeds=$CORE_NETWORK_SEEDS
ntp=true
debug.nopow=true
ntp.pool=pool.ntp.org
partition.fragments=$CORE_PARTITION_FRAGMENTS
universe=$CORE_UNIVERSE
universe.lurking=${CORE_UNIVERSE_LURKING:-0}
universe.witness=${CORE_UNIVERSE_WITNESS:-0}
universe.witnesses=$CORE_UNIVERSE_WITNESSES
node.key.path=./etc/node.key
pump.atoms=${CORE_PUMP_ATOMS_URL}
shards.range=$CHUNK_RANGE
# NOTE: keep this disabled on a public network otherwise your node will get DoS attacked
spamathon.enabled=${CORE_SPAMATHON_ENABLED:-false}
# *FIXME* Temporary test hack for checksum issue
debug.atoms.sync.disable_checksum=true
#debug.atoms.sync.disable_inventory=true
# Pumper should only load atoms for first shard
pump.useSingleShard=true
# Relevant when mem is >= 16GB
dB.cache_size=2147483648
ledger.sync.commit.max=100000
# disable all sync for debugging
EOF

# Configure logger
cat >./logger.config <<EOF
# Use 30 for no debug, 31 to include debug, 0 for no logging
logger.atoms.level=31
logger.general.level=30
logger.network.level=30
logger.messaging.level=30
logger.discovery.level=30
logger.RTP.level=0
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
export JAVA_OPTS="-Djava.library.path=. $JAVA_OPTS"

# load iptables
# TODO: Need to tweak and test this some more before we can enable it in a public network.
if [ "$ENABLE_IPTABLES_RULES" = yes ]; then
    /sbin/iptables-restore < /etc/iptables/iptables.rules
fi

# set -x

# # Download file from google drive
# ggURL='https://drive.google.com/uc?export=download'  
# filename="$(curl -sc /tmp/gcokie "${ggURL}&id=${ggID}" | grep -o '="uc-name.*</span>' | sed 's/.*">//;s/<.a> .*//')"  
# getcode="$(awk '/_warning_/ {print $NF}' /tmp/gcokie)"  
# curl -Lb /tmp/gcokie "${ggURL}&confirm=${getcode}&id=${ggID}" -o atoms.zst  

# # Decompresses file
# unzstd -T0 atoms.zst

# Kick off test at TIMETORUNTEST
sleep_until_time_to_run_test() {
    local now=$(date +%s)
    local future=$(date -d "${TIMETORUNTEST}" +%s)
    [ $future -lt $now ] || sleep $(($future - $now))
    touch /opt/radixdlt/START_PUMP
}
[ -z "$TIMETORUNTEST" ] || sleep_until_time_to_run_test &

# set +x

/sbin/su-exec radix:radix "$@"
