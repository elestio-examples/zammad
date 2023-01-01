# set env vars
# set -o allexport; source .env; set +o allexport;

#fix SSL Reverse proxy for zammad
sed -i '/^proxy_set_header X-Forwarded-Proto.*/a proxy_set_header X-Forwarded-Ssl on;' /opt/elestio/nginx/conf.d/${CI_CD_DOMAIN}.conf
docker exec elestio-nginx nginx -s reload;
