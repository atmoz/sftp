# SFTP with Fail2ban

![GitHub Workflow Status](https://img.shields.io/github/workflow/status/schnuckz/sftp/build?logo=github) ![GitHub stars](https://img.shields.io/github/stars/schnuckz/sftp?logo=github) ![Docker Stars](https://img.shields.io/docker/stars/schnuckz/sftp?label=stars&logo=docker) ![Docker Pulls](https://img.shields.io/docker/pulls/schnuckz/sftp?label=pulls&logo=docker)

# Supported tags and respective `Dockerfile` links

- [`debian`, `latest` (*Dockerfile*)](https://github.com/schnuckz/sftp/blob/master/Dockerfile) ![Docker Image Size (debian)](https://img.shields.io/docker/image-size/schnuckz/sftp/debian?label=debian&logo=debian&style=plastic)

# Securely share your files

Easy to use SFTP ([SSH File Transfer Protocol](https://en.wikipedia.org/wiki/SSH_File_Transfer_Protocol)) server with [OpenSSH](https://en.wikipedia.org/wiki/OpenSSH). Forked from atmoz/sftp. Code also from MarkusMcNugen/docker-sftp
This is an automated build linked with [debian:buster](https://hub.docker.com/r/debian/buster/).

# Docker Features
* Base: debian:buster
* Hardened default ssh config
* Mount only one persistent Volume for all config-files
* Fail2ban
* Optional config volume can be mounted for custom ssh and fail2ban configuration and easily viewing fail2ban log

# Usage

- Define users in (1) command arguments, (2) `SFTP_USERS` environment variable
  or (3) in file mounted as `/config/sshd/users.conf` (syntax:
  `user:pass[:e][:uid[:gid[:dir1[,dir2]...]]] ...`, see below for examples)
  - Set UID/GID manually for your users if you want them to make changes to
    your mounted volumes with permissions matching your host filesystem.
  - Directory names at the end will be created under user's home directory with
    write permission, if they aren't already present.
- Mount volumes
  - The users are chrooted to their home directory, so you can mount the
    volumes in separate directories inside the user's home directory
    (/home/user/**mounted-directory**) or just mount the whole **/home** directory.
    Just remember that the users can't create new files directly under their
    own home directory, so make sure there are at least one subdirectory if you
    want them to upload files.
  - For consistent server fingerprint, mount your own host keys (i.e. `/config/sshd/keys/ssh_host_*`)

# Examples

## Simplest docker run example

```
docker run -p 22:22 -d schnuckz/sftp foo:pass:::upload
```

User "foo" with password "pass" can login with sftp and upload files to a folder called "upload". No mounted directories or custom UID/GID. Later you can inspect the files and use `--volumes-from` to mount them somewhere else (or see next example).

## Sharing a directory from your computer

Let's mount a directory and set UID:

```
docker run \
    -v <host-dir>/upload:/home/foo/upload \
    -p 2222:22 -d schnuckz/sftp \
    foo:pass:1001
```

### Using Docker Compose:

```
sftp:
    image: schnuckz/sftp
    volumes:
        - <host-dir>/upload:/home/foo/upload
    ports:
        - "2222:22"
    command: foo:pass:1001
```

### Logging in

The OpenSSH server runs by default on port 22, and in this example, we are forwarding the container's port 22 to the host's port 2222. To log in with the OpenSSH client, run: `sftp -P 2222 foo@<host-ip>`

## Use Persisten Storage

Only one Persisten Volume for all config & keys.

```
/config/
├── fail2ban
│   ├── fail2ban.log (read only)
│   ├── jail.conf (read only, use jail.local)
│   └── jail.local
├── sshd
│   ├── keys
│   │   ├── ssh_host_ed25519_key
│   │   └── ssh_host_rsa_key
│   ├── scripts
│   │   └── bindmount.sh
│   ├── sshd_config
│   └── users.conf
└── userkeys
    └── foo.pub
```

## Store users in config

```
docker run \
    -v <host-dir>:/config \
    -v mySftpVolume:/home/foo/share \
    -p 2222:22 -d schnuckz/sftp
```

<host-dir>/sshd/users.conf:

```
foo:123:1001:100
bar:abc:1002:100
baz:xyz:1003:100
```

## Encrypted password

Add `:e` behind password to mark it as encrypted. Use single quotes if using terminal.

```
docker run \
    -v <host-dir>/share:/home/foo/share \
    -p 2222:22 -d schnuckz/sftp \
    'foo:$1$0G2g0GSt$ewU0t6GXG15.0hWoOX8X9.:e:1001'
```

Tip: you can use [atmoz/makepasswd](https://hub.docker.com/r/atmoz/makepasswd/) to generate encrypted passwords:  
`echo -n "your-password" | docker run -i --rm atmoz/makepasswd --crypt-md5 --clearfrom=-`

## Logging in with SSH keys

Mount public keys in the user's `.ssh/keys/` directory. All keys are automatically appended to `.ssh/authorized_keys` (you can't mount this file directly, because OpenSSH requires limited file permissions). In this example, we do not provide any password, so the user `foo` can only login with his SSH key.

```
docker run \
    -v <host-dir>:/config \
    -v mySftpVolume:/home/foo/share \
    -p 2222:22 -d atmoz/sftp \
    foo::1001
```

## Providing your own SSH host key (recommended)

This container will generate new SSH host keys at first run. To avoid that your users get a MITM warning when you recreate your container (and the host keys changes), you can mount your own host keys.

```
docker run \
    -v <host-dir>:/config \
    -v mySftpVolume:/home/foo/share \
    -p 2222:22 -d schnuckz/sftp \
    foo::1001
```

<host-dir>/sshd/keys/ssh_host_ed25519_key
<host-dir>/sshd/keys/ssh_host_rsa_key

Tip: you can generate your keys with these commands:

```
ssh-keygen -t ed25519 -f ssh_host_ed25519_key < /dev/null
ssh-keygen -t rsa -b 4096 -f ssh_host_rsa_key < /dev/null
```

## Execute custom scripts or applications

Put your programs in `/config/sshd/scripts/` and it will automatically run when the container starts.
See next section for an example.

## Bindmount dirs from another location

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

# What's the difference between Debian and Alpine?

The biggest differences are in size and OpenSSH version. [Alpine](https://hub.docker.com/_/alpine/) is 10 times smaller than [Debian](https://hub.docker.com/_/debian/). OpenSSH version can also differ, as it's two different teams maintaining the packages. Debian is generally considered more stable and only bugfixes and security fixes are added after each Debian release (about 2 years). Alpine has a faster release cycle (about 6 months) and therefore newer versions of OpenSSH. As I'm writing this, Debian has version 7.4 while Alpine has version 7.5. Recommended reading: [Comparing Debian vs Alpine for container & Docker apps](https://www.turnkeylinux.org/blog/alpine-vs-debian)

# What version of OpenSSH do I get?

It depends on which linux distro and version you choose (see available images at the top). You can see what version you get by checking the distro's packages online. I have provided direct links below for easy access.

- [List of `openssh` packages on Alpine releases](https://pkgs.alpinelinux.org/packages?name=openssh&branch=&repo=main&arch=x86_64)
- [List of `openssh-server` packages on Debian releases](https://packages.debian.org/search?keywords=openssh-server&searchon=names&exact=1&suite=all&section=main)

**Note:** The time when this image was last built can delay the availability of an OpenSSH release. Since this is an automated build linked with [debian](https://hub.docker.com/_/debian/) and [alpine](https://hub.docker.com/_/alpine/) repos, the build will depend on how often they push changes (out of my control).  Typically this can take 1-5 days, but it can also take longer. You can of course make this more predictable by cloning this repo and run your own build manually.
