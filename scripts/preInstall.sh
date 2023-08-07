set env vars
set -o allexport; source .env; set +o allexport;

mkdir -p ./zammad_backup;
mkdir -p ./zammad_data;
mkdir -p ./scripts/backup.sh;
mkdir -p ./elasticsearch_data;
mkdir -p ./postgresql_data;

chmod 777 ./zammad_backup
chmod 777 ./zammad_data
chmod 777 ./scripts/backup.sh
chmod 777 ./elasticsearch_data
chmod 777 ./postgresql_data

chown -R 1001:1001 elasticsearch_data
chown -R 1000:1000 zammad_data
chown -R 1000:1000 zammad_backup