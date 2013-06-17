#!/bin/bash
MYSQL_PASS=${MYSQL_PASS:=$1} #Either use MYSQL_PASS environment variable or first argument to script
THE_SCRIPT=$(basename $0)
if [[ "" == "${MYSQL_PASS}" ]]; then
    echo """
   ___                    _           _     ___  ___    ___                       _           
  / _ \ _ __  ___ _ _  __| |_ __ _ __| |__ |   \| _ )  / __|___ _ _  ___ _ _ __ _| |_ ___ _ _ 
 | (_) | '_ \/ -_) ' \(_-<  _/ _\` / _| / / | |) | _ \ | (_ / -_) ' \/ -_) '_/ _\` |  _/ _ \ '_|
  \___/| .__/\___|_||_/__/\__\__,_\__|_\_\ |___/|___/  \___\___|_||_\___|_| \__,_|\__\___/_|  
       |_|                                                                                                                                        

Usage: ${THE_SCRIPT} mysql_password
or set enviroment variable MYSQL_PASS then run ${THE_SCRIPT}:
MYSQL_PASS=WHATEVER ${THE_SCRIPT}"""
    exit 1
fi
MYSQL_CLIENT=$(which mysql)
if [[ ! $? -eq 0 ]]; then
    echo "mysql client not installed!"
    exit 1
fi
MYSQL_COMMAND="mysql -uroot -p${MYSQL_PASS}"
echo "Checking mysql connection.."
TEST=$(echo "show databases;" | ${MYSQL_COMMAND})
if [[ ! $? -eq 0 ]]; then
    echo """Was not able to connect to mysql, Check password. Error:
${TEST}
"""
    exit 1
fi
SERVICES="keystone glance quantum nova cinder"
for service in ${SERVICES}; do
    echo """
CREATE DATABASE ${service};
GRANT ALL ON ${service}.* TO '${service}User'@'%' IDENTIFIED BY '${service}Pass';
GRANT ALL ON ${service}.* TO '${service}User'@'localhost' IDENTIFIED BY '${service}Pass';
""" | ${MYSQL_COMMAND}
done;
echo "Done"
