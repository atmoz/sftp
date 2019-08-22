# Secure defaults
# See: https://stribika.github.io/2015/01/04/secure-secure-shell.html
Protocol 2
HostKey /etc/ssh/ssh_host_ed25519_key
HostKey /etc/ssh/ssh_host_rsa_key

# Faster connection
# See: https://github.com/atmoz/sftp/issues/11
UseDNS no

# Limited access
PermitRootLogin no
X11Forwarding no
AllowTcpForwarding no

# Force sftp and chroot jail
Subsystem sftp internal-sftp
ForceCommand internal-sftp
ChrootDirectory %h

# Enable this for more logs
#LogLevel VERBOSE
