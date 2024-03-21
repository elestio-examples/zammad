set env vars
set -o allexport; source .env; set +o allexport;


mkdir zammad_backup zammad_data elasticsearch_data postgresql_data
chown -R 1001:1001 elasticsearch_data
chown -R 1000:1000 zammad_data
chown -R 1000:1000 zammad_backup

chmod +x scripts/backup.sh

docker run --rm -v ./zammad_data:/target_volume --user=root --entrypoint /bin/bash zammad/zammad-docker-compose:6.2.0-1 -c "cp -a /opt/zammad /target_volume/"