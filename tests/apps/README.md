<a href="https://elest.io">
  <img src="https://elest.io/images/elestio.svg" alt="elest.io" width="150" height="75">
</a>

[![Discord](https://img.shields.io/static/v1.svg?logo=discord&color=f78A38&labelColor=083468&logoColor=ffffff&style=for-the-badge&label=Discord&message=community)](https://discord.gg/4T4JGaMYrD "Get instant assistance and engage in live discussions with both the community and team through our chat feature.")
[![Elestio examples](https://img.shields.io/static/v1.svg?logo=github&color=f78A38&labelColor=083468&logoColor=ffffff&style=for-the-badge&label=github&message=open%20source)](https://github.com/elestio-examples "Access the source code for all our repositories by viewing them.")
[![Blog](https://img.shields.io/static/v1.svg?color=f78A38&labelColor=083468&logoColor=ffffff&style=for-the-badge&label=elest.io&message=Blog)](https://blog.elest.io "Latest news about elestio, open source software, and DevOps techniques.")

# Budibase, verified and packaged by Elestio

[Budibase](https://budibase.com/) saves teams time and energy building apps that integrate seamlessly with any workflow - coding optional.

<img src="https://github.com/elestio-examples/budibase/raw/main/budibase.png" alt="Budibase" width="800">

[![deploy](https://github.com/elestio-examples/budibase/raw/main/deploy-on-elestio.png)](https://dash.elest.io/deploy?source=cicd&social=dockerCompose&url=https://github.com/elestio-examples/budibase)

Deploy a <a target="_blank" href="https://elest.io/open-source/budibase">fully managed Budibase</a> on <a target="_blank" href="https://elest.io/">elest.io</a> if you want a free and open-source, decentralized, ActivityPub federated video platform powered by WebTorrent, that uses peer-to-peer technology to reduce load on individual servers when viewing videos.

# Why use Elestio images?

- Elestio stays in sync with updates from the original source and quickly releases new versions of this image through our automated processes.
- Elestio images provide timely access to the most recent bug fixes and features.
- Our team performs quality control checks to ensure the products we release meet our high standards.

# Usage

## Git clone

You can deploy it easily with the following command:

    git clone https://github.com/elestio-examples/budibase.git

Copy the .env file from tests folder to the project directory

    cp ./tests/.env ./.env

Edit the .env file with your own values.

Create data folders with correct permissions

    set -o allexport; source .env; set +o allexport;

    mkdir -p ./storage
    chown -R 1000:1000 ./storage

Run the project with the following command

    docker-compose up -d

You can access the Web UI at: `http://your-domain:9445`

## Docker-compose

Here are some example snippets to help you get started creating a container.


        version: "3"

        services:
        app-service:
            restart: unless-stopped
            image: elestio4test/budibase-server:${SOFTWARE_VERSION_TAG}
            container_name: bbapps
            environment:
            SELF_HOSTED: 1
            COUCH_DB_URL: http://${COUCH_DB_USER}:${COUCH_DB_PASSWORD}@couchdb-service:5984
            WORKER_URL: http://worker-service:4003
            MINIO_URL: http://minio-service:9000
            MINIO_ACCESS_KEY: ${MINIO_ACCESS_KEY}
            MINIO_SECRET_KEY: ${MINIO_SECRET_KEY}
            INTERNAL_API_KEY: ${INTERNAL_API_KEY}
            BUDIBASE_ENVIRONMENT: ${BUDIBASE_ENVIRONMENT}
            PORT: 4002
            API_ENCRYPTION_KEY: ${API_ENCRYPTION_KEY}
            JWT_SECRET: ${JWT_SECRET}
            LOG_LEVEL: info
            ENABLE_ANALYTICS: "true"
            REDIS_URL: redis-service:6379
            REDIS_PASSWORD: ${REDIS_PASSWORD}
            BB_ADMIN_USER_EMAIL: ${BB_ADMIN_USER_EMAIL}
            BB_ADMIN_USER_PASSWORD: ${BB_ADMIN_USER_PASSWORD}
            PLUGINS_DIR: ${PLUGINS_DIR}
            OFFLINE_MODE: ${OFFLINE_MODE}
            depends_on:
            - worker-service
            - redis-service
        #    volumes:
        #      - /some/path/to/plugins:/plugins

        worker-service:
            restart: unless-stopped
            image: budibase.docker.scarf.sh/budibase/worker
            container_name: bbworker
            environment:
            SELF_HOSTED: 1
            PORT: 4003
            CLUSTER_PORT: ${MAIN_PORT}
            API_ENCRYPTION_KEY: ${API_ENCRYPTION_KEY}
            JWT_SECRET: ${JWT_SECRET}
            MINIO_ACCESS_KEY: ${MINIO_ACCESS_KEY}
            MINIO_SECRET_KEY: ${MINIO_SECRET_KEY}
            MINIO_URL: http://minio-service:9000
            APPS_URL: http://app-service:4002
            COUCH_DB_USERNAME: ${COUCH_DB_USER}
            COUCH_DB_PASSWORD: ${COUCH_DB_PASSWORD}
            COUCH_DB_URL: http://${COUCH_DB_USER}:${COUCH_DB_PASSWORD}@couchdb-service:5984
            INTERNAL_API_KEY: ${INTERNAL_API_KEY}
            REDIS_URL: redis-service:6379
            REDIS_PASSWORD: ${REDIS_PASSWORD}
            OFFLINE_MODE: ${OFFLINE_MODE}
            depends_on:
            - redis-service
            - minio-service

        minio-service:
            restart: unless-stopped
            image: minio/minio
            volumes:
            - minio_data:/data
            environment:
            MINIO_ACCESS_KEY: ${MINIO_ACCESS_KEY}
            MINIO_SECRET_KEY: ${MINIO_SECRET_KEY}
            MINIO_BROWSER: "off"
            command: server /data --console-address ":9001"
            healthcheck:
            test: "timeout 5s bash -c ':> /dev/tcp/127.0.0.1/9000' || exit 1"
            interval: 30s
            timeout: 20s
            retries: 3

        proxy-service:
            restart: unless-stopped
            ports:
            - "${MAIN_PORT}:10000"
            container_name: bbproxy
            image: budibase/proxy
            environment:
            - PROXY_RATE_LIMIT_WEBHOOKS_PER_SECOND=10
            - PROXY_RATE_LIMIT_API_PER_SECOND=20
            - APPS_UPSTREAM_URL=http://app-service:4002
            - WORKER_UPSTREAM_URL=http://worker-service:4003
            - MINIO_UPSTREAM_URL=http://minio-service:9000
            - COUCHDB_UPSTREAM_URL=http://couchdb-service:5984
            - WATCHTOWER_UPSTREAM_URL=http://watchtower-service:8080
            - RESOLVER=127.0.0.11
            depends_on:
            - minio-service
            - worker-service
            - app-service
            - couchdb-service

        couchdb-service:
            restart: unless-stopped
            image: budibase/couchdb
            pull_policy: always
            environment:
            - COUCHDB_PASSWORD=${COUCH_DB_PASSWORD}
            - COUCHDB_USER=${COUCH_DB_USER}
            - TARGETBUILD=docker-compose
            volumes:
            - couchdb3_data:/opt/couchdb/data

        redis-service:
            restart: unless-stopped
            image: redis
            command: redis-server --requirepass ${REDIS_PASSWORD}
            volumes:
            - redis_data:/data

        watchtower-service:
            restart: always
            image: containrrr/watchtower
            volumes:
            - /var/run/docker.sock:/var/run/docker.sock
            command: --debug --http-api-update bbapps bbworker bbproxy
            environment:
            - WATCHTOWER_HTTP_API=true
            - WATCHTOWER_HTTP_API_TOKEN=budibase
            - WATCHTOWER_CLEANUP=true
            labels:
            - "com.centurylinklabs.watchtower.enable=false"

        volumes:
        couchdb3_data:
            driver: local
        minio_data:
            driver: local
        redis_data:
            driver: local


### Environment variables

|       Variable       |     Value (example)     |
| :------------------: | :---------------------: |
| SOFTWARE_VERSION_TAG |  latest                 |
|     ADMIN_EMAIL      |     your email          |
|  ADMIN_PASSWORD      | admin password          |


# Maintenance

## Logging

The Elestio Budibase Docker image sends the container logs to stdout. To view the logs, you can use the following command:

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

- <a target="_blank" href="https://docs.budibase.com/docs">Budibase documentation</a>

- <a target="_blank" href="https://github.com/Budibase/budibase">Budibase Github repository</a>

- <a target="_blank" href="https://github.com/elestio-examples/budibase">Elestio/Budibase Github repository</a>
