Compatible with docker-compose v2 schemas.

```yaml
---
version: "2.1"
services:
  heimdall:
    image: ghcr.io/linuxserver/heimdall
    container_name: heimdall
    environment:
      - PUID=1000
      - PGID=1000
      - TZ=Europe/London
    volumes:
      - </path/to/appdata/config>:/config
    ports:
      - 80:80
      - 443:443
    restart: unless-stopped
```

### docker cli

```
docker run -d \
  --name=heimdall \
  -e PUID=1000 \
  -e PGID=1000 \
  -e TZ=Europe/London \
  -p 80:80 \
  -p 443:443 \
  -v </path/to/appdata/config>:/config \
  --restart unless-stopped \
  ghcr.io/linuxserver/heimdall
```


## Parameters

Container images are configured using parameters passed at runtime (such as those above). These parameters are separated by a colon and indicate `<external>:<internal>` respectively. For example, `-p 8080:80` would expose port `80` from inside the container to be accessible from the host's IP on port `8080` outside the container.

| Parameter | Function |
| :----: | --- |
| `-p 80` | http gui |
| `-p 443` | https gui |
| `-e PUID=1000` | for UserID - see below for explanation |
| `-e PGID=1000` | for GroupID - see below for explanation |
| `-e TZ=Europe/London` | Specify a timezone to use EG Europe/London |
| `-v /config` | Contains all relevant configuration files. |

## Environment variables from files (Docker secrets)

You can set any environment variable from a file by using a special prepend `FILE__`.

As an example:

```
-e FILE__PASSWORD=/run/secrets/mysecretpassword
```

Will set the environment variable `PASSWORD` based on the contents of the `/run/secrets/mysecretpassword` file.

## Umask for running applications

For all of our images we provide the ability to override the default umask settings for services started within the containers using the optional `-e UMASK=022` setting.
Keep in mind umask is not chmod it subtracts from permissions based on it's value it does not add. Please read up [here](https://en.wikipedia.org/wiki/Umask) before asking for support.

## User / Group Identifiers

When using volumes (`-v` flags) permissions issues can arise between the host OS and the container, we avoid this issue by allowing you to specify the user `PUID` and group `PGID`.

Ensure any volume directories on the host are owned by the same user you specify and any permissions issues will vanish like magic.

In this instance `PUID=1000` and `PGID=1000`, to find yours use `id user` as below:

```
  $ id username
    uid=1000(dockeruser) gid=1000(dockergroup) groups=1000(dockergroup)
```


&nbsp;
## Application Setup

Access the web gui at http://SERVERIP:PORT


### Adding password protection

This image now supports password protection through htpasswd. Run the following command on your host to generate the htpasswd file `docker exec -it heimdall htpasswd -c /config/nginx/.htpasswd <username>`. Replace <username> with a username of your choice and you will be asked to enter a password. New installs will automatically pick it up and implement password protected access. Existing users updating their image can delete their site config at `/config/nginx/site-confs/default` and restart the container after updating the image. A new site config with htpasswd support will be created in its place.


## Docker Mods
[![Docker Mods](https://img.shields.io/badge/dynamic/yaml?color=94398d&labelColor=555555&logoColor=ffffff&style=for-the-badge&label=heimdall&query=%24.mods%5B%27heimdall%27%5D.mod_count&url=https%3A%2F%2Fraw.githubusercontent.com%2Flinuxserver%2Fdocker-mods%2Fmaster%2Fmod-list.yml)](https://mods.linuxserver.io/?mod=heimdall "view available mods for this container.") [![Docker Universal Mods](https://img.shields.io/badge/dynamic/yaml?color=94398d&labelColor=555555&logoColor=ffffff&style=for-the-badge&label=universal&query=%24.mods%5B%27universal%27%5D.mod_count&url=https%3A%2F%2Fraw.githubusercontent.com%2Flinuxserver%2Fdocker-mods%2Fmaster%2Fmod-list.yml)](https://mods.linuxserver.io/?mod=universal "view available universal mods.")

We publish various [Docker Mods](https://github.com/linuxserver/docker-mods) to enable additional functionality within the containers. The list of Mods available for this image (if any) as well as universal mods that can be applied to any one of our images can be accessed via the dynamic badges above.


## Support Info

* Shell access whilst the container is running: `docker exec -it heimdall /bin/bash`
* To monitor the logs of the container in realtime: `docker logs -f heimdall`
* container version number
  * `docker inspect -f '{{ index .Config.Labels "build_version" }}' heimdall`
* image version number
  * `docker inspect -f '{{ index .Config.Labels "build_version" }}' ghcr.io/linuxserver/heimdall`

## Updating Info

Most of our images are static, versioned, and require an image update and container recreation to update the app inside. With some exceptions (ie. nextcloud, plex), we do not recommend or support updating apps inside the container. Please consult the [Application Setup](#application-setup) section above to see if it is recommended for the image.

Below are the instructions for updating containers:

### Via Docker Compose
* Update all images: `docker-compose pull`
  * or update a single image: `docker-compose pull heimdall`
* Let compose update all containers as necessary: `docker-compose up -d`
  * or update a single container: `docker-compose up -d heimdall`
* You can also remove the old dangling images: `docker image prune`

### Via Docker Run
* Update the image: `docker pull ghcr.io/linuxserver/heimdall`
* Stop the running container: `docker stop heimdall`
* Delete the container: `docker rm heimdall`
* Recreate a new container with the same docker run parameters as instructed above (if mapped correctly to a host folder, your `/config` folder and settings will be preserved)
* You can also remove the old dangling images: `docker image prune`

### Via Watchtower auto-updater (only use if you don't remember the original parameters)
* Pull the latest image at its tag and replace it with the same env variables in one run:
  ```
  docker run --rm \
  -v /var/run/docker.sock:/var/run/docker.sock \
  containrrr/watchtower \
  --run-once heimdall
  ```
* You can also remove the old dangling images: `docker image prune`

**Note:** We do not endorse the use of Watchtower as a solution to automated updates of existing Docker containers. In fact we generally discourage automated updates. However, this is a useful tool for one-time manual updates of containers where you have forgotten the original parameters. In the long term, we highly recommend using [Docker Compose](https://docs.linuxserver.io/general/docker-compose).

### Image Update Notifications - Diun (Docker Image Update Notifier)
* We recommend [Diun](https://crazymax.dev/diun/) for update notifications. Other tools that automatically update containers unattended are not recommended or supported.

## Building locally

If you want to make local modifications to these images for development purposes or just to customize the logic:
```
git clone https://github.com/linuxserver/docker-heimdall.git
cd docker-heimdall
docker build \
  --no-cache \
  --pull \
  -t ghcr.io/linuxserver/heimdall:latest .
```

The ARM variants can be built on x86_64 hardware using `multiarch/qemu-user-static`
```
docker run --rm --privileged multiarch/qemu-user-static:register --reset
```

Once registered you can define the dockerfile to use with `-f Dockerfile.aarch64`.

## Versions

* **10.02.21:** - Revert to alpine 3.12 as php 7.4 broke laravel.
* **10.02.21:** - Rebasing to alpine 3.13.
* **17.08.20:** - Add php7-curl.
* **01.06.20:** - Rebasing to alpine 3.12.
* **17.01.20:** - Use nginx from baseimage.
* **19.12.19:** - Rebasing to alpine 3.11.
* **16.07.19:** - Save laravel.log to /config/log/heimdall.
* **28.06.19:** - Rebasing to alpine 3.10.
* **01.04.19:** - Fix permission detect logic.
* **26.03.19:** - Install Heimdall during container start to prevent delayed start due to overlayfs bug with recursive chown.
* **23.03.19:** - Switching to new Base images, shift to arm32v7 tag.
* **15.03.19:** - Clarify docker image tags in readme.
* **22.02.19:** - Rebasing to alpine 3.9.
* **16.01.18:** - Generate random app key in .env for new installs.
* **20.11.18:** - Upgrade baseimage packages during build.
* **04.11.18:** - Add php7-zip.
* **31.10.18:** - Add queue service.
* **17.10.18:** - Symlink avatars folder.
* **16.10.18:** - Updated fastcgi_params for user login support.
* **07.10.18:** - Symlink `.env` rather than copy. It now resides under `/config/www`
* **30.09.18:** - Multi-arch image. Move `.env` to `/config`.
* **05.09.18:** - Rebase to alpine linux 3.8.
* **06.03.18:** - Use password protection if htpasswd is set. Existing users can delete their default site config at /config/nginx/site-confs/default and restart the container, a new default site config with htpasswd support will be created in its place
* **12.02.18:** - Initial Release.
