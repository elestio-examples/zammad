set env vars
set -o allexport; source .env; set +o allexport;


mkdir zammad_backup zammad_data elasticsearch_data postgresql_data
chown -R 1000:0 elasticsearch_data
chown -R 1000:1000 zammad_data
chown -R 1000:1000 zammad_backup
