# HOW TO READ TCP STREAM ON REMOTE SERVER

### 1. Open a terminal window

### 2. Forward a Unix socket from the local machine to a Unix socket on the remote machine 

```shell
ssh -L /tmp/fluwide.sock:/var/run/docker.sock fluwide
```

```text
The command ssh -L /tmp/fluwide.sock:/var/run/docker.sock fluwide sets up local port forwarding through SSH. 
However, instead of specifying ports, it forwards a Unix socket from the local machine to a Unix socket on the remote machine.

Here's what each part of the command means:

1)ssh
- Initiates an SSH connection.
2) -L /tmp/fluwide.sock:/var/run/docker.sock
- Specifies the local endpoint (/tmp/fluwide.sock) and the remote endpoint (/var/run/docker.sock) for the forwarding. 
- This means that connections to the local Unix socket /tmp/fluwide.sock on your machine will be forwarded to the Unix socket /var/run/docker.sock on the remote machine.
3) fluwide
- This is the username or hostname of the remote machine you want to SSH into.
- So, when you execute this command, any communication directed to /tmp/fluwide.sock on your local machine will be securely tunneled through SSH and sent to /var/run/docker.sock on the fluwide remote machine. This is often used to access Docker's API on a remote machine securely.
```

> Leave the ssh terminal open  

### 3. Open another terminal window

### 4. Set Docker host env var

```shell
export DOCKER_HOST=unix:///tmp/fluwide.sock
```

```text
The command export DOCKER_HOST=unix:///tmp/fluwide.sock sets the environment variable DOCKER_HOST to the value unix:///tmp/fluwide.sock.

In Docker, the DOCKER_HOST environment variable specifies the Docker daemon's address. 
By default, Docker communicates with the Docker daemon over a TCP socket, typically at tcp://localhost:2375 or tcp://localhost:2376 for secure connections. 
However, by setting DOCKER_HOST to unix:///tmp/fluwide.sock, you're instructing Docker to communicate with the Docker daemon via a Unix socket located at /tmp/fluwide.sock instead of over a network.

Unix sockets provide a way for processes on the same system to communicate with each other, similar to TCP/IP sockets but with lower overhead and without network access. 
In this case, setting DOCKER_HOST to a Unix socket means that Docker client commands will communicate directly with the Docker daemon running on the local system through the specified Unix socket file.

This setup is often used for local Docker communication or when Docker is configured to run without exposing its API over the network for security reasons.
```

### 5. Start tcpdump container

```shell
docker run --name tcpdump -it --net container:<remote-container-id> nicolaka/netshoot tcpdump -i any -w /tmp/dump.pcap
```

```text
Things to note:
1) -it: 
- Allocates a pseudo-TTY and keeps STDIN open even if not attached. 
- This allows interaction with the container's shell
2) --net container:<remote-container-id>:
- Specifies the networking mode for the container. 
- It makes the container share the network namespace with another container specified by its ID `<remote-container-id>`
- This means that the networking stack of the container named "tcpdump" will be the same as that of the container with ID `<remote-container-id>`.
3) tcpdump -i any -w /tmp/dump.pcap
- This is the command to execute within the container 
- It runs tcpdump, a packet analyzer, capturing traffic on all interfaces (-i any) and writes the captured packets to a file named dump.pcap located at /tmp directory inside the container.
```

### 6. Make request to container with <remote-container-id>

Make request in another window (or on a browser)

### 7. Copy TCP Dump

```shell
docker cp tcpdump:/tmp/dump.pcap ~/Desktop/fluwide.com.pcap
```

```text
This command copies a file named dump.pcap from a Docker container named "tcpdump" to the local machine's desktop directory.

Here's the breakdown:

1) docker cp
- This is the Docker command used to copy files or directories between a Docker container and the local filesystem.
2) tcpdump:/tmp/dump.pcap: 
- Specifies the source of the copy operation. 
- In this case, it refers to the file dump.pcap located in the /tmp directory of the Docker container named "tcpdump".
3) ~/Desktop/fluwide.com.pcap
- Specifies the destination path for the copied file on the local filesystem. 
- Here, it indicates the desktop directory (~/Desktop) of the current user's home directory, and the file will be named fluwide.com.pcap.
```

### 8. Open pcap file in Wireshark

### 9. Cleanup

```shell
docker rm -f tcpdump
```