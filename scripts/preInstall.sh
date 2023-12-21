#set env vars
set -o allexport; source .env; set +o allexport;

mkdir -p ./storage
chown -R 1000:1000 ./storage

TOKEN=$(openssl rand -base64 32)

cat << EOT > ./.env

ADMIN_TOKEN=${TOKEN}
EOT
