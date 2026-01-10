create a folder : mkdir /root/Docker/mysql

create the .env with the mysql root password


!!! IMPORTANT !!!
 if you want to change the root password again after the first installation you wii need
 to change it inside the mysql container . changing it via the .env will not change . it is only
 for the first time


create the .yaml file 

docker compose -f /root/Docker/mysql/mysql.yaml up -d # start the container 

!!! IMPORTANT !!!
it will create a mysql volume . DON'T DELETE THAT VOLUME . IF YOU DO SO ALL OF YOUR DB WITH THE DATA
WILL BE GONE 

for the mysql container we will not be having nginx configuration ( so we are not going to be using the host firewall ether , since docker has it's own firewall) , because i am not going to be accposing mysql to my network ,
since only services that are on the same server will be using it ( zabbix , etc...) . so we are going to be playing with docker network . mysql container will create a mysql network that every services that is going to be using the db ( zabbix ) , in THIER .yaml file must not create their own network but use " external = true " with the mysql network in order for the services to be in the same docker network with the mysql.(see zabbix.yaml)

create a conf.d folder with the dependencies .cnf that the services will need for the db.

 dependencies that services ( like zabbix ) that mysql needs add the to the conf.d


 STILL IF YOU ARE EXPOSING TO NGINX OR NOT ( FOR BOTH ) THE DB MUST BE 127.0.0.1 FOR SECURITY !!!!!!