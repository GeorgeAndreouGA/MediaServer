create a folder : mkdir /root/Docker/dockge

add the dockge.yaml file  # the FULL terminal support through dockge ( control the entire system from the dockge terminal ) is turned off 

trough the dockge.yaml file for security reasons. You can control each container though their terminal in dockge. (inside the container only !!!!)

now you have to copy ( symbolic links don't work at the time of writing this ) all of your .yaml or .yml files to the 

/opt/stacks/  (mounted on the dockge.yaml file )

FOR NGINX YOU HAVE TO ADD IT ONLY WITH " / " AND NOT WITH " /DOCKGE " LIKE N8N IT DOESN'T LIKE IT . SEE NGINX CONFIGS

!!!! IMPORTANT !!! FOLLOW THIS METHOD FOR EVERY CONTAINER YOU WANT TO MONITOR.


e.g for emby container.   

1. locate your  emby.yaml. Mine is in /root/Docker/emby/emby.yaml

2. create a folder name emby ( your service name ) in /opt/stacks 

3. copy your emby.yaml ( including any .env files ) file to /opt/stacks/emby but WITH THE NAME compose.yaml or else dockge won't find it .

3.1 cp /root/Docker/emby/emby.yaml /opt/stacks/emby/compose.yaml

3.2 if you have a .env :  cp /root/Docker/emby/.env /opt/stacks/emby/.env

now do the same for every other container you want to monitor.


