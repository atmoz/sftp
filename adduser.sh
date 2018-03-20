#/bin/bash

USER_CONF=/mnt/volume/config/users.conf
HOME_DIR=/mnt/volume/home
SFTP_UID=$(id -u nobody)
SFTP_GID=$(id -g nobody)

function add_user() {
  local user=$1
  
  echo -n "Enter 1 for password auth or 2 for ssh keypair: "
  read auth_type

  if [ "${auth_type}" -eq 1 ]; then
    add_user_password "${user}"
  elif [ "${auth_type}" -eq 2 ]; then
    add_user_pubkey "${user}"
  else
    echo "Invalid selection."
    exit 1
  fi
}

function add_user_password() {
  local user=$1

  echo -n "Enter password (plaintext): "
  read password

  password_enc=$(echo -n "${password}" | docker run -i --rm atmoz/makepasswd --crypt-md5 --clearfrom=- | awk '{print $2}')

  echo "${user}:${password_enc}:e:${SFTP_UID}:${SFTP_GID}:upload" >> ${USER_CONF}

  echo "User ${user} added."
}


function add_user_pubkey () {
  local user=$1

  echo -n "Enter SSH public key: "
  read pubkey

  echo "${user}::e:${SFTP_UID}:${SFTP_GID}:upload" >> ${USER_CONF}
 
  mkdir -p ${HOME_DIR}/${user}/.ssh/keys
  echo "${pubkey}" > ${HOME_DIR}/${user}/.ssh/keys/pubkey.pub

  echo "User ${user} added."
}

function restart() {
  docker-compose down
  docker-compose rm
  docker-compose up -d
}

function usage() {
  echo "Invalid usage."
  echo "$0 <add|delete> <username>"
  exit 1
}


function main() {
  local action=$1
  local user=$2

  if [ "${action}" == "add" ]; then
    add_user "${user}"
    restart
  elif [ "${action}" == "delete" ]; then
    del_user "${user}"
  else 
    usage
  fi
}

main $@
