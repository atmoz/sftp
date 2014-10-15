sftp
====

Simple and easy to use SFTP server based on Debian

Usage
-----

- Define users and passwords in comma separated list with SFTP_USERS ("user1:pass1,user2:pass2").
- Mount volumes in user's home folder.

The users are chrooted to their home folders, so it is important to mount the volumes in separate folders inside the user's home folder (/home/your-user/**your-folder**).

Examples
--------

Simple (one user and one folder):

```
docker run \
    -e SFTP_USERS="foo:123" \
    -v "/sftp/share:/home/foo/share" \
    -p 2222:22 -d atmoz/sftp
```

Multiple users and folders:

```
docker run \
    -e SFTP_USERS="foo:123,bar:abc" \
    -v "/sftp/share:/home/foo/share" \
    -v "/sftp/ebooks:/home/foo/ebooks" \
    -v "/sftp/http:/home/bar/http" \
    -p 2222:22 -d atmoz/sftp
```

