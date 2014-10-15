sftp
====

SFTP Docker image

Usage
-----


- Define users and passwords in comma separated list with SFTP_USERS ("user1:pass1,user2:pass2").
- Mount volumes in user's home folder.

The users are chrooted to their home folders, so it is important to mount the volumes in separate folders inside the user's home folder (/home/your-user/**your-folder**).

Example
-------

```
docker run \
    -e SFTP_USERS="foo:pass,bar:pass" \
    -v "ebooks:/home/foo/ebooks" \
    -v "http:/home/bar/http" \
    -p 2222:22 -d atmoz/sftp
```

