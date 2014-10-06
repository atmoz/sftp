sftp
====

SFTP Docker image

Usage
-----

Define users and passwords in comma separated list (user1:pass1,user2:pass2), and mount filesystem as folder in user's home folder.

```
docker run \
    -e SFTP_USERS="<some-user>:<password>,<another-user>:<password>" \
    -v some-dir:/home/<some-user>/some-dir \
    -v another-dir:/home/<another-user>/another-dir \
    -p 2222:22 -d atmoz/sftp
```

