# docker-php-fpm

Manage DockerHub builds for php-fpm at ZOL

The intended purpose of this repository is to provide branches and tags for a docker image with php-fpm and composer, with a system of branches and tags instead of a directory.

See [CHANGELOG](CHANGELOG.md) for all available versions.

## How to update

If you want to apply updates on this repository, checkout to the current tag you want to start with, create a new branch and apply your updates. Finally, tag the changes with a comprehensive changelog.

Before pushing your changes, make sure it works by building the image locally :

    docker build -t php-fpm:test .

## Rules to follow

- All versions must extend dockerfile official php fpm image, no alpine allowed.
    
- PHP versions must be specific (`7.3.16` instead of only `7.3`)

- Each change must come with an updated [CHANGELOG](CHANGELOG.md)

## Notable facts

UID / GID : existing `www-data` user is updated to have UID and GID 1000, to avoid permissions problems with mounted directories. If you have yourself an user with another UID / GID, you can change your own UID / GID or extends this image in your own Dockerfile like this (where 1001 is your UID) :

```Dockerfile
FROM zolweb/php-fpm:7.3.16
RUN usermod -u 1001 www-data \
    && groupmod -g 1001 www-data \
    && find / -user 1000 -exec chown -h 1001 {} \; || true \
    && find / -group 1000 -exec chgrp -h 1001 {} \; || true \
    && usermod -g 1001 www-data \
    && chown -R 1001:1001 /opt/scripts
```

Installed packages : this image should be used for development only, it contains multiple packages that may not be needed for production. Use it at your own risk.

## Dockerhub

This project is built on [dockerhub, on zolweb account](https://hub.docker.com/repository/docker/zolweb/php-fpm). Images are free to use and come AS IS. ZOL is not responsible for any mis-usage or any problem it may cause.

Automatic building is enabled, any tag push or master push trigger a build as following :

| Source | Type | Tag docker |
|:------:|:----:|:----------:|
| master | branch | latest |
| /^[0-9.]+/ | tag | {sourceref} |

Examples :
- Pushing the tag `7.3.16` gives the image `zolweb/php-fpm:7.3.16`
- Pushing the tag `7.4.4-composer-1.10.1` gives the image `zolweb/php-fpm:7.4.4-composer-1.10.1`
- Pushing to `master` updates the image `zolweb/php-fpm:latest`

You should not use `latest` tag, as the push order on this repository is done following our own needs, not PHP versions. Use tag instead.