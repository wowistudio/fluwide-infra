# HOW TO RUN CONTAINERS IN A DIFFERENT DOCKER CONTEXT

In this way you can deploy projects to a remote machine without the need of a container registry.

### 1. Create new docker context

```shell
docker context create myctx --docker "host=ssh://root@<server-ip>"
```

```text
This command is creating a Docker context named "myctx" with specific configurations for connecting to a Docker host via SSH.

Let's break down the command:
1) docker context create: 
- This is the command used to create a new Docker context. 
- Docker contexts allow you to switch between different Docker environments easily.

2) myctx: 
- This is the name given to the Docker context being created. 
- You can name it whatever you like; in this case, it's named "myctx".

3) --docker ...
- This part specifies the Docker host configuration. 
- It's using SSH to connect to the Docker host. 

4) host=ssh://root@<server-ip>
- This specifies the hostname and user to use for SSH connection. 
- In this case, it's connecting to an SSH server running at the IP address <server-ip>, with the username root.
```

### 2. Build in context

```shell
docker --context myctx buildx build --platform linux/amd64 -t myctx:latest .
```

```text

This command is utilizing Docker Buildx, a Docker CLI plugin for extended build capabilities with BuildKit. 
It's instructing Docker to build an image using the Docker context named "myctx".

Let's break down the command:
1) docker --context myctx buildx build
- This part of the command invokes Docker Buildx to initiate a build process. 
- Buildx extends Docker CLI with the ability to build images using BuildKit.
- It provides advanced features like multi-platform builds.
2) --platform linux/amd64
- This flag specifies the platform(s) for which the image should be built. 
- In this case, it's specifying that the image should be built for the Linux architecture with an AMD64 processor.
3) -t myctx:latest
- This flag tags the built image with a name and a tag. 
- The name of the image is set to "myctx" and the tag is set to "latest". 
- This means that the resulting image will be named "myctx" and will have the tag "latest".
```

### 3. Run in context

...

### For Makefile

```shell
docker --context myctx rm -f myctx
docker --context myctx run \
    --detach \
    --restart unless-stopped \
    --name myimage \
    -v "/root/state:/app/state" \
    -e UBER_FETCH=True \
    -e UBER_LOOP=True \
    -e UBER_TELEGRAM_SEND=True \
    -e PYTHONUNBUFFERED=1 \
    myimage:latest
```

```
setup:
	docker context create myctx --docker "host=ssh://root@<server-ip>"

build:
	docker --context myctx buildx build --platform linux/amd64 -t myimage:latest .

deploy:
	docker --context myctx rm -f myctx
	docker --context myctx run \
		--detach \
		--restart unless-stopped \
		--name myimage \
		-v "/root/state:/app/state" \
		-e UBER_FETCH=True \
		-e UBER_LOOP=True \
		-e UBER_TELEGRAM_SEND=True \
		-e PYTHONUNBUFFERED=1 \
		myimage:latest
```