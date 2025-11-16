create a folder : mkdir /root/Docker/pi-hole

create  the pi-hole.yaml file  and the .env

After you have the correct .yaml file => docker compose -f /root/Docker/pi-hole/pi-hole.yaml up -d # start the container

 use nxinx config

 Just like n8n pi-hole can't serve under domain.com:port/something . It has to be domain.com:port/ or  subdomain.domain.com:port/ ( nginx config is already configure)
 go in cloudflare and make a CNAME to one of you domains and use that

USE HTTPS CONNECTION ( GENERATE SSL CERT FIRST)
 CONFIGURING PI - HOLE AS A LOCAL DNS SERVER . 

 After you have succesfully logged in go :

   1. settings -> DNS -> And turn on Expert mode 

   2. choose " Permit all origins " ( it is safe sinse we are not exposing port 53 to the world ) we are doing this because we are using docker

   3. under " Advanced DNS settings BOTH " Never forward reverse lookups for private IP ranges " and " Never forward non-FQDN queries " MUST BE TURNED OFF and " Use DNSSEC" 
      you can turn it on if you NS ( NAMESERVER ) supports it . Since our NS is cloudflare we can go and turn " Use DNSSEC " in the cloudflare settings and then in the pi-hole settings
      ( i have it off but you can turn it on if you have the support )

   4. after that go to : settings -> local dns settings -> and under the " List of local dns settings " point your domain to the ip ( you can do that not only for the server's domains sevices but also for others)

   5. Go to your Routers settings and under the dhcp section you MUST change the PRIMARY DNS to your Server's ip and if you want add a secondary dns ( not neccessary) 

   6. Turn off your router and then turn it on ( now how ever conncets to your router he will go through your pi - hole and will get the adblocking and the local dns)

   DONE



    !!!! IMPORTANT !!! YOUR HOST DEVICES MUST NOT OVVERRIGHT THE PRIMARY DNS OR ELSE IT WON'T CONNECT TO THE PI - HOLE . 
    CLEAR YOU HOST DEVICES CAHCH AND COOKIES ( if it is for the first time ) AND MAKE SURE THAT PRIVATE DNS ( USUALY ON ANDROID ) IS OFF ( NOT PRIMARY )

    RIMENDER : IF DNS FAILS YOU CAN ALWAYS USE THE PRIVATE IP OF THE SEVRER ( SEE NGINX CONFIG)