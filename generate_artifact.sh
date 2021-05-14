#!/usr/bin/env bash


export RADIXDLT_VALIDATOR_HOST=127.0.0.1
export RADIXDLT_VALIDATOR_TCP_PORT=30001
export RADIXDLT_CLIENT_HTTP_PORT=8081
export RADIXDLT_NODE_API_PORT=3334
export NGINX_VALIDATOR_TCP_PORT=30000
export NGINX_CLIENT_HTTP_PORT=8080
export NGINX_NODE_HTTP_PORT=3333

#Remove the nginx configuration part and generate nginx.conf
for node_type in full_node archive_node;do
  if [[ "$node_type" == "full_node" ]]; then
    nginx_file_name="nginx-fullnode.conf"
  elif [[ "$node_type" == "archive_node" ]]; then
    export RADIXDLT_ENABLE_CLIENT_API=true
    nginx_file_name="nginx-archive.conf"
  fi
  sed '1,/# nginx configuration/!d' docker-entrypoint.sh  | sed 's/\/etc\/nginx/${PWD}/g' | bash
  mv ${PWD}/nginx.conf ${PWD}/$nginx_file_name
  #Remove nginx user
  sed -i "s|user nginx;|include \/etc\/nginx\/modules-enabled\/*.conf;|g" ${PWD}/$nginx_file_name
  #Change /dev/stdout
  sed -i "s|\/dev\/stdout|\/var\/log\/nginx\/access.log|g" ${PWD}/$nginx_file_name

  if [[ "$node_type" == "full_node" ]]; then
    zip -r radixdlt-nginx-fullnode-conf.zip conf.d/ nginx-fullnode.conf
  elif [[ "$node_type" == "archive_node" ]]; then
    zip -r radixdlt-nginx-archive-conf.zip conf.d/ nginx-archive.conf
  fi
done
#Cleanup
rm nginx-archive.conf nginx-fullnode.conf

