# SFTP

![GitHub Workflow Status](https://img.shields.io/github/workflow/status/atmoz/sftp/build?logo=github) ![GitHub stars](https://img.shields.io/github/stars/atmoz/sftp?logo=github) ![Docker Stars](https://img.shields.io/docker/stars/atmoz/sftp?label=stars&logo=docker) ![Docker Pulls](https://img.shields.io/docker/pulls/atmoz/sftp?label=pulls&logo=docker)

![OpenSSH logo](https://raw.githubusercontent.com/atmoz/sftp/master/openssh.png "Powered by OpenSSH")

# Supported tags and respective `Dockerfile` links

- [`debian`, `latest` (*Dockerfile*)](https://github.com/atmoz/sftp/blob/master/Dockerfile) ![Docker Image Size (debian)](https://img.shields.io/docker/image-size/atmoz/sftp/debian?label=debian&logo=debian&style=plastic)
- [`alpine` (*Dockerfile*)](https://github.com/atmoz/sftp/blob/master/Dockerfile-alpine) ![Docker Image Size (alpine)](https://img.shields.io/docker/image-size/atmoz/sftp/alpine?label=alpine&logo=Alpine%20Linux&style=plastic)

# Securely share your files

Easy to use SFTP ([SSH File Transfer Protocol](https://en.wikipedia.org/wiki/SSH_File_Transfer_Protocol)) server with [OpenSSH](https://en.wikipedia.org/wiki/OpenSSH).

# Usage for Kubernetes cluster

## Creating your own SSH key

Generate your keys with these commands:

```
ssh-keygen -t ed25519 -f ssh_host_ed25519_key < /dev/null
ssh-keygen -t rsa -b 4096 -f ssh_host_rsa_key < /dev/null
```

## Create secret using the keys

Lets create a secret using the generated keys (private key)

```
kubectl create secret generic sftp-key --from-file=ssh_host_ed25519_key --from-file=ssh_host_rsa_key
```

## Store users in config

Create config map with users value `(user:pass[:e][:uid[:gid...]])`. Multiple users can be added.

```
apiVersion: v1
kind: ConfigMap
metadata:
  name: sftp-config
data:
  users.conf: |
    foo:123:1001:100
```

## Sharing a directory from your computer

- ### Add shared location as volume in deployment

    Ex: You can mount host directory to share your location. You can also add other types of volumes as well. For more on [volumes](https://kubernetes.io/docs/concepts/storage/volumes/) 

```
volumes:
....
- name: location
  hostPath:
    path: <path-to-host-dir>
```

- ### Mount the volume in the container

```
containers:
- name: sftp-client
  volumeMounts:
  ...
  - name: location
    mountPath: /home/<user>/<mounted-directory>
```

- ### Expose the service

    Add a service for the deployment to access the sftp client outside the cluster. Select a nodeport from the range.

```
apiVersion: v1
kind: Service
metadata:
  labels:
    app: sftp-client
  name: sftp-client
spec:
  ports:
  - name: ssh
    port: 22
    targetPort: 22
    nodePort: <30000-32767>
  selector:
    app: sftp-client
  type: NodePort
```

## Apply the manifest in the cluster

Create all the resource in the cluster with the command.

```
kubectl apply -f ./kubernetes
```

## Logging in 

The OpenSSH server runs by default on port 22, and in this example, we are forwarding the container's port 22 to the service's nodeport. To log in with the OpenSSH client, run: 

```
sftp -P <nodeport> <user>@<worker-node-ip>
```
