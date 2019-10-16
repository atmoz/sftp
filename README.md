# SFTP

Forked from atmoz to make it easier to setup on kubernetes and share a volume to a group of people. 
adds fail2ban from [this pr](https://github.com/atmoz/sftp/pull/189). 
merges in a number of PRs to fix a number of issues

![Docker Automated build](https://img.shields.io/docker/cloud/automated/yakworks/sftp.svg) ![Docker Build Status](https://img.shields.io/docker/cloud/build/yakworks/sftp.svg) ![Docker Stars](https://img.shields.io/docker/stars/yakworks/sftp.svg) ![Docker Pulls](https://img.shields.io/docker/pulls/yakworks/sftp.svg)

<img src="docs/openssh.png"
	title="A cute kitten" height="80" />
<img src="docs/docker-logo-png-transparent.png" 
	title="A cute kitten" height="80" />
<img src="docs/wordpress-kubernetes.png" 
	title="A cute kitten" height="80" />

<!-- TOC depthfrom:2 -->

- [Supported tags and respective `Dockerfile` links](#supported-tags-and-respective-dockerfile-links)
- [Example Quickstart](#example-quickstart)
- [Summary](#summary)
    - [Simplest docker run example](#simplest-docker-run-example)
- [Volume `data` mount](#volume-data-mount)
    - [Examples](#examples)
- [User File - users.conf](#user-file---usersconf)
- [Encrypted passwords](#encrypted-passwords)
- [Logging in with SSH keys](#logging-in-with-ssh-keys)
- [Providing your own SSH host key (recommended)](#providing-your-own-ssh-host-key-recommended)
- [Execute custom scripts or applications](#execute-custom-scripts-or-applications)
- [Bindmount dirs from another location](#bindmount-dirs-from-another-location)

<!-- /TOC -->
## Supported tags and respective `Dockerfile` links

- [`debian`, `latest` (*Dockerfile*)](https://github.com/yakworks/docker-sftp/blob/master/Dockerfile) [![](https://images.microbadger.com/badges/version/yakworks/sftp.svg)](https://microbadger.com/images/yakworks/sftp "Get your own version badge on microbadger.com")
[![](https://images.microbadger.com/badges/image/yakworks/sftp.svg)](https://microbadger.com/images/yakworks/sftp "Get your own image badge on microbadger.com")

**Securely share your files**

Easy to use SFTP ([SSH File Transfer Protocol](https://en.wikipedia.org/wiki/SSH_File_Transfer_Protocol)) server with [OpenSSH](https://en.wikipedia.org/wiki/OpenSSH).
This is an automated build linked with the [debian](https://hub.docker.com/_/debian/) repositories.


## Example Quickstart

to run the opionionated example in this project `./examples/docker-run.sh`

## Summary

- Define users in (1) command arguments, (2) `SFTP_USERS` environment variable
  or (3) in file mounted as `/etc/sftp/users.conf` (syntax:
  `user:pass[:e][:uid[:gid[:dir1[,dir2]...]]] ...`, see below for examples)
  - Set UID/GID manually for your users if you want them to make changes to
    your mounted volumes with permissions matching your host filesystem.
  - If uid is not specified then it will be automatically created starting at 1000
  - If GID is not specified then it will default to 100:users
  - Directory names at the end will be created under user's home directory with
    write permission, if they aren't already present.
  - if a dir is not specified then it defaults to `/home/:user/data`

- **Fail2Ban** is configured with intelligent defaults and the logs for both var/log/auth.log 
  and /var/log/  fail2ban.conf is tailed to the output for docker and kubernetes
  - for fail2ban to work it needs the `--cap-add=NET_ADMIN` permissions added to docker. if your running into 
    issues then, while not recomended, you can brute force it with `--privileged`
  - in kubernetes the container should have 
    ```
    securityContext:
      privileged: true # only need
      capabilities:
        add: ["SYS_ADMIN", "NET_ADMIN"]
    ```

### Simplest docker run example

```
docker run -p 2222:22 -d yakworks/sftp foo:pass
```

The OpenSSH server runs by default on port 22, and in this example, we are forwarding the container's port 22 to the host's port 2222. To log in with the OpenSSH client, run: `sftp -P 2222 foo@127.0.0.1`

User "foo" with password "pass" can login with sftp and upload files to the default folder called "data". No mounted directories or custom UID/GID. Later you can inspect the files and use `--volumes-from` to mount them somewhere else (or see next example).

NOTE: in this example Fail2Ban will probably fail as it needs the NET_ADMIN capability

## Volume `data` mount

Opinionated permission defaults 

- if the data volume is mounted then it will create `/data/users/:user` for each user under it
- **staff/owner group**: a `staff` or `50` group is considered an owner, ex:`foo:pass::staff`.
  They will have `/data` link mounted to their `/home/:user/data` and will have full rw access to the whole dir.
- **users group**: a `users` or `100` group is considered limited in visibility, ex:`foo:pass::user`
  They will have the `/data/users/:user` link mounted to `/home/:user/data` and will be limitd to that dir
- `--cap-add=SYS_ADMIN` is needed for the mounting. see kubernetes example for adding securityContext.capabilities
- set the DATA_MOUNT_NAME env can be set to change the name from `data`.  

### Examples

Let's mount a directory and make a user and staf owner with UIDs as well. 

```
mkdir -p target/onebox-sftp

docker run --cap-add=NET_ADMIN --cap-add=SYS_ADMIN \
  -e DATA_MOUNT_NAME=onebox \
  -v $(pwd)/target/onebox-sftp:/data \
  -p 2222:22 -d yakworks/sftp \
  owner1:pass::staff user1:pass::users
```

In this example when they owner1 user sftp's in they will have a `onebox` dir that is essentially mapped to the 
`target/onebox-sftp` dir via the `data` share. 
The user1 will end up having a `target/onebox-sftp/users/user1` dir created for them and they will also see a
`onebox` dir when stping that is mapped and restricted to that dir. 

Go ahead and try out fail2ban. enter 5 bad logins and see what happens. 

## User File - users.conf

```
echo "
owner:123:1001:staff
bar:abc:1006:100
baz:xyz:1098:users
" >> target/users.conf

docker run --cap-add=NET_ADMIN --cap-add=SYS_ADMIN  \
    -v $(pwd)/target/users.conf:/etc/sftp/users.conf:ro \
    -v $(pwd)/store/onebox-sftp:/data \
    -p 2222:22 -d yakworks/sftp
```

note: 100 is the `users` group so either id will work or name

In this example it will create 

## Encrypted passwords

Add `:e` behind password to mark it as encrypted. Use single quotes if using terminal.

```
docker run \
    -v /host/share:/home/foo/share \
    -p 2222:22 -d yakworks/sftp \
    'foo:$1$0G2g0GSt$ewU0t6GXG15.0hWoOX8X9.:e:1001'
```

Tip: you can use [atmoz/makepasswd](https://hub.docker.com/r/atmoz/makepasswd/) to generate encrypted passwords:  
`echo -n "your-password" | docker run -i --rm atmoz/makepasswd --crypt-md5 --clearfrom=-`

## Logging in with SSH keys

Mount public keys in the user's `.ssh/keys/` directory. All keys are automatically appended to `.ssh/authorized_keys` (you can't mount this file directly, because OpenSSH requires limited file permissions). In this example, we do not provide any password, so the user `foo` can only login with his SSH key.

```
docker run \
    -v /host/id_rsa.pub:/home/foo/.ssh/keys/id_rsa.pub:ro \
    -v /host/id_other.pub:/home/foo/.ssh/keys/id_other.pub:ro \
    -v /host/share:/home/foo/share \
    -p 2222:22 -d atmoz/sftp \
    foo::1001
```

## Providing your own SSH host key (recommended)

For consistent server fingerprint, mount your own host keys (i.e. `/etc/ssh/ssh_host_*`)

This container will generate new SSH host keys at first run. To avoid that your users get a MITM warning when you recreate your container (and the host keys changes), you can mount your own host keys.

```
docker run \
    -v /host/ssh_host_ed25519_key:/etc/ssh/ssh_host_ed25519_key \
    -v /host/ssh_host_rsa_key:/etc/ssh/ssh_host_rsa_key \
    -v /host/share:/home/foo/share \
    -p 2222:22 -d atmoz/sftp \
    foo::1001
```

Tip: you can generate your keys with these commands:

```
ssh-keygen -t ed25519 -f ssh_host_ed25519_key < /dev/null
ssh-keygen -t rsa -b 4096 -f ssh_host_rsa_key < /dev/null
```

## Execute custom scripts or applications

Put your programs in `/etc/sftp.d/` and it will automatically run when the container starts.
See next section for an example.

## Bindmount dirs from another location

- Users are chrooted to their home directory, so you can mount the
  volumes in separate directories inside the user's home directory
  (/home/user/**mounted-directory**) or just mount the whole **/home** directory.
  Just remember that the users can't create new files directly under their
  own home directory, so make sure there are at least one subdirectory if you
  want them to upload files.

If you are using `--volumes-from` or just want to make a custom directory available in user's home directory, you can add a script to `/etc/sftp.d/` that bindmounts after container starts.

```
#!/bin/bash
# File mounted as: /etc/sftp.d/bindmount.sh
# Just an example (make your own)

function bindmount() {
    if [ -d "$1" ]; then
        mkdir -p "$2"
    fi
    mount --bind $3 "$1" "$2"
}

# Remember permissions, you may have to fix them:
# chown -R :users /data/common

bindmount /data/admin-tools /home/admin/tools
bindmount /data/common /home/dave/common
bindmount /data/common /home/peter/common
bindmount /data/docs /home/peter/docs --read-only
```

**NOTE:** Using `mount` requires that your container runs with the `CAP_SYS_ADMIN` capability turned on. [See this answer for more information](https://github.com/atmoz/sftp/issues/60#issuecomment-332909232).
