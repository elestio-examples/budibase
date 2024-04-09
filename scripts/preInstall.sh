#set env vars
set -o allexport; source .env; set +o allexport;

echo 'vm.overcommit_memory = 1' >> /etc/sysctl.conf && sysctl -p

mkdir -p ./couchdb3_data && chown -R 1001:1001 ./couchdb3_data