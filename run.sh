#!/bin/bash

DATADIR=$(mysqld --verbose --help --log-bin-index=`mktemp -u` 2>/dev/null | awk '$1 == "datadir" { print $2; exit }')
ls -l $DATADIR

if [ ! -d "$DATADIR/mysql" ]; then
    mkdir -p "$DATADIR"
    chown -R mysql:mysql "$DATADIR"

    mysql_install_db --datadir="$DATADIR" --user=mysql

    chown -R mysql:mysql "$DATADIR"

    mysqld_safe > /tmp/mysqld.log 2>&1 &

    RET=1
    while [[ RET -ne 0 ]]; do
        echo "=> Waiting for confirmation of MySQL service startup"
        sleep 5
        mysql -uroot -e "status" > /dev/null 2>&1
        RET=$?
    done

    MYSQL_PASS=$(< /dev/urandom tr -dc _A-Z-a-z-0-9 | head -c${1:-32};echo;)

    mysql -uroot -e "CREATE USER 'ampache'@'%' IDENTIFIED BY '${MYSQL_PASS}'"
    mysql -uroot -e "GRANT ALL PRIVILEGES ON *.* TO 'ampache'@'%' WITH GRANT OPTION"

    echo "MySQL ampache password: ${MYSQL_PASS}"

    mysqladmin -uroot shutdown
fi

cp -n /tmp/ampache_config/* /opt/ampache/config/

chown ampache: /opt/ampache/config/ -R

service mysql start

php -S 0.0.0.0:8080
