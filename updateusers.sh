#!/bin/bash
source /dbenv.sh

echo " select 'groupadd '||login||'; useradd --gid ' || login || ' '||login||' ;' || 'echo -e '''||password||'\n'||password||''''||' |passwd '||login as comd from sftpaccounts where login is not null and password is not null;" >sql


psql -h proddb.pocnettech.com -A clearinghouse < sql|grep "'">/fixusers.sh
chmod +x /fixusers.sh

cat /fixusers.sh
/fixusers.sh