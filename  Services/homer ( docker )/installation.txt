create a folder : mkdir /root/Docker/homer

create  the emby.yaml file = >   choose your architecture https://hub.docker.com/r/b4bz/homer


In the .yaml we have =>
                                 volumes:
                                - /root/Docker/homer/config:/www/assets # Make sure your local config directory exists
                                  ports:
                                - "127.0.0.1:8080:8080"

!!! important !!! make sure that they are correct ( like emby )

docker compose -f /root/Docker/homer/homer.yaml up -d # start the container 

 Now make changes to the nginx  ( config file for services after-cerbot-ssl-cert )


 Homer works with the config.yml file . create it under the /root/Docker/homer/config ( this path will be created automaticaly after you start the container )

 you can add more services to the config.yml