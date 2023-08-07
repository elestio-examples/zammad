<a href="https://elest.io">
  <img src="https://elest.io/images/elestio.svg" alt="elest.io" width="150" height="75">
</a>

[![Discord](https://img.shields.io/static/v1.svg?logo=discord&color=f78A38&labelColor=083468&logoColor=ffffff&style=for-the-badge&label=Discord&message=community)](https://discord.gg/4T4JGaMYrD "Get instant assistance and engage in live discussions with both the community and team through our chat feature.")
[![Elestio examples](https://img.shields.io/static/v1.svg?logo=github&color=f78A38&labelColor=083468&logoColor=ffffff&style=for-the-badge&label=github&message=open%20source)](https://github.com/elestio-examples "Access the source code for all our repositories by viewing them.")
[![Blog](https://img.shields.io/static/v1.svg?color=f78A38&labelColor=083468&logoColor=ffffff&style=for-the-badge&label=elest.io&message=Blog)](https://blog.elest.io "Latest news about elestio, open source software, and DevOps techniques.")

# Zammad, verified and packaged by Elestio

[Zammad](https://github.com/zammad/zammad.git) is the helpdesk software of the future and helps you find structure in the chaos.

<img src="https://github.com/elestio-examples/zammad/raw/main/zammad.png" alt="zammad" width="800">

Deploy a <a target="_blank" href="https://elest.io/open-source/zammad">fully managed Zammad</a> on <a target="_blank" href="https://elest.io/">elest.io</a> if you want to connect all your communication channels, easily grant user rights, and receive helpful reporting.

[![deploy](https://github.com/elestio-examples/zammad/raw/main/deploy-on-elestio.png)](https://dash.elest.io/deploy?source=cicd&social=dockerCompose&url=https://github.com/elestio-examples/zammad)

# Why use Elestio images?

- Elestio stays in sync with updates from the original source and quickly releases new versions of this image through our automated processes.
- Elestio images provide timely access to the most recent bug fixes and features.
- Our team performs quality control checks to ensure the products we release meet our high standards.

# Usage

## Git clone

You can deploy it easily with the following command:

    git clone https://github.com/elestio-examples/zammad.git

Copy the .env file from tests folder to the project directory

    cp ./tests/.env ./.env

Edit the .env file with your own values.

Create data folders with correct permissions

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

Run the project with the following command

    docker-compose up -d

You can access the Web UI at: `http://your-domain:8784`

## Docker-compose

Here are some example snippets to help you get started creating a container.

    version: "3.3"

    services:
    zammad-backup:
        command: ["zammad-backup"]
        depends_on:
        - zammad-railsserver
        - zammad-postgresql
        entrypoint: /usr/local/bin/backup.sh
        environment:
        - BACKUP_SLEEP=86400
        - HOLD_DAYS=10
        - POSTGRESQL_USER=${POSTGRES_USER}
        - POSTGRESQL_PASSWORD=${POSTGRES_PASS}
        image: postgres:${POSTGRES_VERSION}
        restart: ${RESTART}
        volumes:
        - ./zammad_backup:/var/tmp/zammad
        - ./zammad_data:/opt/zammad:ro
        - ./scripts/backup.sh:/usr/local/bin/backup.sh

    zammad-elasticsearch:
        image: bitnami/elasticsearch:8.5.1
        restart: ${RESTART}
        volumes:
        - ./elasticsearch_data:/bitnami/elasticsearch/data

    zammad-init:
        command: ["zammad-init"]
        depends_on:
        - zammad-postgresql
        environment:
        - MEMCACHE_SERVERS=${MEMCACHE_SERVERS}
        - POSTGRESQL_USER=${POSTGRES_USER}
        - POSTGRESQL_PASS=${POSTGRES_PASS}
        - REDIS_URL=${REDIS_URL}
        image: ${IMAGE_REPO}:${SOFTWARE_VERSION_TAG}
        restart: on-failure
        volumes:
        - ./zammad_data:/opt/zammad

    zammad-memcached:
        command: memcached -m 256M
        image: memcached:1.6.17-alpine
        restart: ${RESTART}

    zammad-nginx:
        command: ["zammad-nginx"]
        ports:
        - "172.17.0.1:8784:8080"
        depends_on:
        - zammad-railsserver
        image: ${IMAGE_REPO}:${SOFTWARE_VERSION_TAG}
        environment:
        - NGINX_SERVER_SCHEME=https
        restart: ${RESTART}
        volumes:
        - ./zammad_data:/opt/zammad

    zammad-postgresql:
        environment:
        - POSTGRES_USER=${POSTGRES_USER}
        - POSTGRES_PASSWORD=${POSTGRES_PASS}
        image: postgres:${POSTGRES_VERSION}
        restart: ${RESTART}
        volumes:
        - ./postgresql_data:/var/lib/postgresql/data

    zammad-railsserver:
        command: ["zammad-railsserver"]
        depends_on:
        - zammad-memcached
        - zammad-postgresql
        - zammad-redis
        environment:
        - MEMCACHE_SERVERS=${MEMCACHE_SERVERS}
        - REDIS_URL=${REDIS_URL}
        image: ${IMAGE_REPO}:${SOFTWARE_VERSION_TAG}
        restart: ${RESTART}
        volumes:
        - ./zammad_data:/opt/zammad

    zammad-redis:
        image: redis:7.0.5-alpine
        restart: ${RESTART}

    zammad-scheduler:
        command: ["zammad-scheduler"]
        depends_on:
        - zammad-memcached
        - zammad-railsserver
        - zammad-redis
        image: ${IMAGE_REPO}:${SOFTWARE_VERSION_TAG}
        restart: ${RESTART}
        volumes:
        - ./zammad_data:/opt/zammad

    zammad-websocket:
        command: ["zammad-websocket"]
        depends_on:
        - zammad-memcached
        - zammad-railsserver
        - zammad-redis
        environment:
        - MEMCACHE_SERVERS=${MEMCACHE_SERVERS}
        - REDIS_URL=${REDIS_URL}
        image: ${IMAGE_REPO}:${SOFTWARE_VERSION_TAG}
        restart: ${RESTART}
        volumes:
        - ./zammad_data:/opt/zammad

# Maintenance

## Logging

The Elestio Zammad Docker image sends the container logs to stdout. To view the logs, you can use the following command:

    docker-compose logs -f

To stop the stack you can use the following command:

    docker-compose down

## Backup and Restore with Docker Compose

To make backup and restore operations easier, we are using folder volume mounts. You can simply stop your stack with docker-compose down, then backup all the files and subfolders in the folder near the docker-compose.yml file.

Creating a ZIP Archive
For example, if you want to create a ZIP archive, navigate to the folder where you have your docker-compose.yml file and use this command:

    zip -r myarchive.zip .

Restoring from ZIP Archive
To restore from a ZIP archive, unzip the archive into the original folder using the following command:

    unzip myarchive.zip -d /path/to/original/folder

Starting Your Stack
Once your backup is complete, you can start your stack again with the following command:

    docker-compose up -d

That's it! With these simple steps, you can easily backup and restore your data volumes using Docker Compose.

# Links

- <a target="_blank" href="https://github.com/zammad/zammad.git">Zammad Github repository</a>

- <a target="_blank" href="https://docs.zammad.org/">Zammad documentation</a>

- <a target="_blank" href="https://github.com/elestio-examples/zammad">Elestio/Zammad Github repository</a>
