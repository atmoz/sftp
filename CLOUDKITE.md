# Requirements

* GCE/EC2 Instance with an external IP address
* PV/EBS mounted at /mnt/volume GCE Instance

# Installation steps

## Switch system SSH to use port 2222 to allow for SFTP on port 22
This requires that the firewall is open on both TCP/22 (for sftp) and TCP/2222 (for ssh)
```bash
sed -i 's/#Port 22$/Port 2222/' /etc/ssh/sshd_config
systemctl restart sshd
(log out and log back in on port 2222)
```

## Setup SFTP Host Keys
```bash
mkdir -p /mnt/volume/config
ssh-keygen -t ed25519 -f /mnt/volume/config/ssh_host_ed25519_key < /dev/null
ssh-keygen -t rsa -b 4096 -f /mnt/volume/config/ssh_host_rsa_key < /dev/null
```

## Install sftp scripts
```bash
git clone https://github.com/cloudkite-io/sftp.git
```

# User Management
At least one user needs to be added before Docker will start
```bash
adduser.sh <add|delete> <username>
```

# Start service 
```bash
docker-compose up --build -d
```
