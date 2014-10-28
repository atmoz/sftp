sftp
====

Easy to use SFTP (*SSH File Transfer Protocol*) server.

Usage
-----

- Define users as last arguments to `docker run`, one user per argument  
  (syntax: `user:pass[:e][:[uid][:gid]]`).
  - You must set custom UID for your users if you want them to make changes to
    your mounted volumes with permissions matching your host filesystem.
- Mount volumes in user's home folder.
  - The users are chrooted to their home directory, so you must mount the
    volumes in separate directories inside the user's home directory
    (/home/user/**mounted-directory**).

Examples
--------

### Single user and volume

```
docker run \
    -v /host/share:/home/foo/share \
    -p 2222:22 -d atmoz/sftp \
    foo:123:1001
```

### Multiple users and volumes

```
docker run \
    -v /host/share:/home/foo/share \
    -v /host/documents:/home/foo/documents \
    -v /host/http:/home/bar/http \
    -p 2222:22 -d atmoz/sftp \
    foo:123:1001 \
    bar:abc:1002
```

### Encrypted password

Add `:e` behind password to mark it as encrypted. Use single quotes.

```
docker run \
    -v /host/share:/home/foo/share \
    -p 2222:22 -d atmoz/sftp \
    'foo:$1$0G2g0GSt$ewU0t6GXG15.0hWoOX8X9.:e:1001'
```

Tip: you can use makepasswd to generate encrypted passwords:  
`echo -n 123 | makepasswd --crypt-md5 --clearfrom -`

### Using SSH key (without password)

```
docker run \
    -v /host/id_rsa.pub:/home/foo/.ssh/authorized_keys:ro \
    -v /host/share:/home/foo/share \
    -p 2222:22 -d atmoz/sftp \
    foo::1001
```
