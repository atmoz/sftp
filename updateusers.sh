#!/bin/bash
source /dbenv.sh




echo " select 'groupadd '||login||'; useradd --gid ' || login || ' '||login||' ;' || 'echo -e '''||password||'\n'||password||''''||' |passwd '||login as comd from sftpaccounts where login is not null and password is not null;" >sql
echo "select 'mkdir -p /home/'||login||'/home/'||login||'; chmod 755  /home/' || login ||';if [  -d \"/sourcehome/'||login||'\" ]; then mount --bind /sourcehome/'|| login || ' /home/'||login||'/home/'||login||'; fi' as comd from sftpaccounts where login is not null and password is not null;">sql2


psql -h proddb.pocnettech.com -A clearinghouse < sql|grep "'">/fixusers.sh
psql -h proddb.pocnettech.com -A clearinghouse < sql2|grep mkdir>>/fixusers.sh

chmod +x /fixusers.sh

cat /fixusers.sh
/fixusers.sh