

create a folder : mkdir /root/Docker/emby

create  the emby.yaml file = >   choose your architecture https://emby.media/docker-server.html


in the emby.yaml you have :  volumes:
                            - /root/Docker/emby/config:/config # Configuration directory !!! important !!! the /root/Docker/emby/config will be created automatically on the directory where we seted up the emby.yaml file.    the /config directory is where the /root/Docker/emby/config will be mounted in the docker container 
                            - /path/to/your_media:/mnt/media  # Media directory    !!! important !!! the /path/to/your_media is where you containt is located on your server. CHANGE IT TO YOUR MEDIA DIRECTORY ( you can mount the entire /media directory if you want to ) . It will be mounted in the docker container to /mnt/media
                             
                             ports:
                             - "127.0.0.18096:8096"  # localhost only !!!!
   
   !!!IMPORTANT !!! choose correct for the above

    After you have the correct .yaml file => docker compose -f /root/Docker/emby/emby.yaml up -d # start the container 

 Now make changes to the nginx  ( config file for services after-cerbot-ssl-cert )


 THE config file that emby will create ( the one you will mount ) MUST HAVE yourUser:yourUser or yourUser:users ( NO ROOT VERY IMPORTANT)    privilages . use chown to change.