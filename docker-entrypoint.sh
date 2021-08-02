#!/bin/sh

set -e

[ "$NGINX_RESOLVER" ] || export NGINX_RESOLVER=$(awk '$1=="nameserver" {print $2;exit;}' </etc/resolv.conf)

[ "$RADIXDLT_VALIDATOR_HOST" ] || export RADIXDLT_VALIDATOR_HOST=core
[ "$RADIXDLT_VALIDATOR_TCP_PORT" ] || export RADIXDLT_VALIDATOR_TCP_PORT=30000
[ "$RADIXDLT_CLIENT_HTTP_PORT" ] || export RADIXDLT_CLIENT_HTTP_PORT=8080
[ "$RADIXDLT_NODE_API_PORT" ] || export RADIXDLT_NODE_API_PORT=3333
[ "$NGINX_VALIDATOR_TCP_PORT" ] || export NGINX_VALIDATOR_TCP_PORT=30000
[ "$NGINX_CLIENT_HTTP_PORT" ] || export NGINX_CLIENT_HTTP_PORT=8080



[ "$RADIXDLT_FAUCET_API_ENABLE" ] || export RADIXDLT_FAUCET_API_ENABLE=false
if [[ "$RADIXDLT_FAUCET_API_ENABLE" == true || "$RADIXDLT_FAUCET_API_ENABLE" == "True" ]];then
  export INCLUDE_RADIXDLT_FAUCET_ENABLED="include conf.d/faucet-conf.conf;"
  DOLLAR='$' envsubst </etc/nginx/conf.d/faucet-conf.conf.envsubst >/etc/nginx/conf.d/faucet-conf.conf
fi

[ "$RADIXDLT_ARCHIVE_API_ENABLE" ] || export RADIXDLT_ARCHIVE_API_ENABLE=false
if [[ "$RADIXDLT_ARCHIVE_API_ENABLE" == true || "$RADIXDLT_ARCHIVE_API_ENABLE" == "True" ]];then
  export INCLUDE_RADIXDLT_ARCHIVE_API_ENABLE="include conf.d/archive-conf.conf;"
  DOLLAR='$' envsubst </etc/nginx/conf.d/archive-conf.conf.envsubst >/etc/nginx/conf.d/archive-conf.conf
fi

[ "$RADIXDLT_CONSTRUCTION_API_ENABLE" ] || export RADIXDLT_CONSTRUCTION_API_ENABLE=false
if [[ "$RADIXDLT_CONSTRUCTION_API_ENABLE" == true || "$RADIXDLT_CONSTRUCTION_API_ENABLE" == "True" ]];then
  construnction_conf_file="construction-conf"
  export INCLUDE_RADIXDLT_CONSTRUCTION_API_ENABLE="include conf.d/${construnction_conf_file}.conf;"
  DOLLAR='$' envsubst </etc/nginx/conf.d/${construnction_conf_file}.conf.envsubst >/etc/nginx/conf.d/${construnction_conf_file}.conf
fi

[ "$RADIXDLT_CHAOS_API_ENABLE" ] || export RADIXDLT_CHAOS_API_ENABLE=false
if [[ "$RADIXDLT_CHAOS_API_ENABLE" == true || "$RADIXDLT_CHAOS_API_ENABLE" == "True" ]];then
  export INCLUDE_RADIXDLT_CHAOS_API_ENABLE="include conf.d/chaos-conf.conf;"
  DOLLAR='$' envsubst </etc/nginx/conf.d/chaos-conf.conf.envsubst >/etc/nginx/conf.d/chaos-conf.conf
fi

[ "$RADIXDLT_UNIVERSE_ENABLE" ] || export RADIXDLT_UNIVERSE_ENABLE=true
if [[ "$RADIXDLT_UNIVERSE_ENABLE" == true || "$RADIXDLT_UNIVERSE_ENABLE" == "True" ]];then
  export INCLUDE_RADIXDLT_UNIVERSE_ENABLE="include conf.d/universe-conf.conf;"
  DOLLAR='$' envsubst </etc/nginx/conf.d/universe-conf.conf.envsubst >/etc/nginx/conf.d/universe-conf.conf
fi

[ "$RADIXDLT_ENABLE_SYSTEM_API" ] || export RADIXDLT_ENABLE_SYSTEM_API=true
if [[ "$RADIXDLT_ENABLE_SYSTEM_API" == true || "$RADIXDLT_ENABLE_SYSTEM_API" == "True" ]];then
  export INCLUDE_RADIXDLT_ENABLE_SYSTEM_API="include conf.d/system-conf.conf;"
  DOLLAR='$' envsubst </etc/nginx/conf.d/system-conf.conf.envsubst >/etc/nginx/conf.d/system-conf.conf
fi

[ "$RADIXDLT_ENABLE_ACCOUNT_API" ] || export RADIXDLT_ENABLE_ACCOUNT_API=true
if [[ "$RADIXDLT_ENABLE_ACCOUNT_API" == true || "$RADIXDLT_ENABLE_ACCOUNT_API" == "True" ]];then
  conf_file="account-conf"
  export INCLUDE_RADIXDLT_ENABLE_ACCOUNT_API="include conf.d/${conf_file}.conf;"
  DOLLAR='$' envsubst </etc/nginx/conf.d/${conf_file}.conf.envsubst >/etc/nginx/conf.d/${conf_file}.conf
fi


[ "$RADIXDLT_ENABLE_VALIDATION_API" ] || export RADIXDLT_ENABLE_VALIDATION_API=true
if [[ "$RADIXDLT_ENABLE_VALIDATION_API" == true || "$RADIXDLT_ENABLE_VALIDATION_API" == "True" ]];then
  conf_file="validation-conf"
  export INCLUDE_RADIXDLT_ENABLE_VALIDATION_API="include conf.d/${conf_file}.conf;"
  DOLLAR='$' envsubst </etc/nginx/conf.d/${conf_file}.conf.envsubst >/etc/nginx/conf.d/${conf_file}.conf
fi

[ "$RADIXDLT_ENABLE_HEALTH_API" ] || export RADIXDLT_ENABLE_HEALTH_API=true
if [[ "$RADIXDLT_ENABLE_HEALTH_API" == true || "$RADIXDLT_ENABLE_HEALTH_API" == "True" ]];then
  conf_file="health-conf"
  export INCLUDE_RADIXDLT_ENABLE_HEALTH_API="include conf.d/${conf_file}.conf;"
  DOLLAR='$' envsubst </etc/nginx/conf.d/${conf_file}.conf.envsubst >/etc/nginx/conf.d/${conf_file}.conf
fi

[ "$RADIXDLT_ENABLE_VERSION_API" ] || export RADIXDLT_ENABLE_VERSION_API=true
if [[ "$RADIXDLT_ENABLE_VERSION_API" == true || "$RADIXDLT_ENABLE_VERSION_API" == "True" ]];then
  conf_file="version-conf"
  export INCLUDE_RADIXDLT_ENABLE_VERSION_API="include conf.d/${conf_file}.conf;"
  DOLLAR='$' envsubst </etc/nginx/conf.d/${conf_file}.conf.envsubst >/etc/nginx/conf.d/${conf_file}.conf
fi

[ "$RADIXDLT_ENABLE_METRICS_API" ] || export RADIXDLT_ENABLE_METRICS_API=true
if [[ "$RADIXDLT_ENABLE_METRICS_API" == true || "$RADIXDLT_ENABLE_METRICS_API" == "True" ]];then
  conf_file="metrics-conf"
  export INCLUDE_RADIXDLT_ENABLE_METRICS_API="include conf.d/${conf_file}.conf;"
  DOLLAR='$' envsubst </etc/nginx/conf.d/${conf_file}.conf.envsubst >/etc/nginx/conf.d/${conf_file}.conf
fi

#Developer endpoints need to be avaiable for all nodes and networks
conf_file="developer-conf"
export INCLUDE_RADIXDLT_ENABLE_DEVELOPER_API="include conf.d/${conf_file}.conf;"
DOLLAR='$' envsubst </etc/nginx/conf.d/${conf_file}.conf.envsubst >/etc/nginx/conf.d/${conf_file}.conf

DOLLAR='$' envsubst </etc/nginx/conf.d/nginx.conf.envsubst >/etc/nginx/nginx.conf

# nginx configuration
# Generate dhparam.pem if not pre-configured
if [ ! -f /etc/nginx/secrets/dhparam.pem ]; then
    # TODO: increase to 2048 for Beta
    openssl dhparam -out /etc/nginx/secrets/dhparam.pem  1024
fi

# Generate certificates if not pre-configured
if [ ! -f /etc/nginx/secrets/server.pem -o ! -f /etc/nginx/secrets/server.key ]; then
    # remove old links
    rm -f /etc/nginx/secrets/server.pem /etc/nginx/secrets/server.key
    openssl req  -nodes -new -x509 -nodes -subj '/CN=localhost' -keyout /etc/nginx/secrets/server.key -out /etc/nginx/secrets/server.pem
fi

generate_password() {
    local password=$3
    if [ -z "$password" ]; then
        password=$(openssl rand -base64 32)
        echo "==> Your new $2 password is: $password <=="
    fi
    printf "$2:%s" $(openssl passwd -apr1 "$password") > "$1"
}

# Generate htpasswd files if not pre-configured
[ -z "$ADMIN_PASSWORD" -a "$WIPE_ADMIN_PASSWORD" != yes ] || \
    rm -f /etc/nginx/secrets/htpasswd.admin
[ -z "$METRICS_PASSWORD" -a "$WIPE_METRICS_PASSWORD" != yes ] || \
    rm -f /etc/nginx/secrets/htpasswd.metrics
[ -z "$SUPER_ADMIN_PASSWORD" -a "$SUPER_ADMIN_PASSWORD" != yes ] || \
    rm -f /etc/nginx/secrets/htpasswd.admin

[ -f /etc/nginx/secrets/htpasswd.admin ] || \
    generate_password /etc/nginx/secrets/htpasswd.admin "${ADMIN_USER:-admin}" "${ADMIN_PASSWORD}"
[ -f /etc/nginx/secrets/htpasswd.metrics ] || \
    generate_password /etc/nginx/secrets/htpasswd.metrics "${METRICS_USER:-metrics}" "${METRICS_PASSWORD}"
[ -f /etc/nginx/secrets/htpasswd.metrics ] || \
    generate_password /etc/nginx/secrets/htpasswd.superadmin "${SUPER_ADMIN_USER:-superadmin}" "${SUPER_ADMIN_PASSWORD}"
unset ADMIN_USER ADMIN_PASSWORD METRICS_USER METRICS_PASSWORD SUPER_ADMIN_USER SUPER_ADMIN_PASSWORD

exec "$@"
