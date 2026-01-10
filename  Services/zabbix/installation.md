FIRST SETUP THE mysql container 

create a folder : mkdir /root/Docker/zabbix

In the "build_zabbix_db_mysql.sql " go and change the zabbix db password


go inside the mysql container and load the " build_zabbix_db_mysql.sql " . It will create the user and db for zabbix 


go to the " conf.d " folder of mysql and add the " zabbix-fix.cnf " ( see mysql folder)

create the .env that has all of the credential of the db for zabbix (add the password for the zabbix db during the "build_zabbix_db_mysql.sql " setup)


create the .yaml file and then : docker compose -f /root/Docker/zabbix/zabbix.yaml up -d # start the container

!!! NOTE !!! the .yaml files has three containers ( server , web , agent ) for nginx we are exposing only the web

see " nginx config file for services after-cerbot-ssl-cert ( that need only a domain and not a subdomain ).conf "