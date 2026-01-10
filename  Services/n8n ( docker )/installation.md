create a folder : mkdir /root/Docker/n8n

create  the n8n.yaml file  and the .env

After you have the correct .yaml file => docker compose -f /root/Docker/n8n/n8n.yaml up -d # start the container


 # make sure the n8n-data privilages are set yourUser:youUser ( use chown ) ( VERY IMPORTANT )  NOT ROOT VERY IMPORTANT


 use ls -la to see ownership 


 use nxinx config


 !!!! IMPORTANT !!!! in the n8n if you are going to set up a scheduler to ping you INTERNAL SERVICES ( emby , Netdata etc...)
 you have to use the same aproach as the other sevices in order for n8n container to see your internal services dispite 
 beeing on the same network as your server ( actauly they are not since each container hase it's own ip with its own subnet ).
 container are isolated inviroments so think of it as a separete server ( like a vm , almost ) that is trying to access your 
 domain.com that is not publicly available. So what we do for every other service ( what we did for emby , homer etc...)? 
 After exposing thier container to 127.0.0.1:hostport:containerport we used nginx and ufw firewall to allow internal ip's,(only internal ip's,vpn subnet (zerotier is installed on our
 server) and we can also add docker container ip's( better add the container subnet because each time the container goes down and then back up it gets another ip but stays on the same 
 subnet. Each container gets its own subnet -> own ip address ( diferent from the host)) since we exposed it only to an internal port with no port forward . 
 If we set a public ip in the firewall and nginx allow list ,  it will fail to access the services due to that reason.) So for n8n to be able to " see " the services domain.com 
 we have to :

 1) find the subnet of the container that n8n is in :   1.a)docker ps -a ( list all container with their id ) 
                                                    
                                                        1.b) docker exec -it < container id > sh   ( get inside the container ) 
                                                       
                                                        1.c) ip a ( list the network adapters with thier ip, you should only see 2 : the loopback (127.0.0.1 ) BUT THIS IS THE LOOPBACK FOR THAT CONTAINER AND NOT THE HOST)

                                                        you should find something like : 127.32.0.5/16 ( this is the containers ip. We want to use the container subnet (172.32.0.0/16) because the ip is dynamic)
 
 
 2) go to nginx and under each location /yourService  in the allow section add the subnet of n8n container ( see nginx config )


 3) Allow the subnet to access the internal port of your services ( mine is 8443 ) :      ufw allow from 172.32.0.0/16 to any port 8443 proto tcp
                                                  
 4) Now in order  for our whitlist ip's (devices) to access the domain we have to edit thier /etc/hosts file ( each one , SEE READ FIRST.txt). Since docker containers
    are isolated inviroments and we tread them like a new device in the .yaml file of n8n we have to add (see n8n.yaml) : extra_hosts:
                                                                                                                           - "subdomain.domain.com:private_ip_of_server"
YOU CAN SKIP 4 IF YOUR ROUTER SUPPORTS LOCAL DNS OVVERIGHT ( for this we are going to be using pi-hole)

!!!DONE!!! Always make the quastion: how is trying to access my services ? ( in this case n8n). What do i have to do in order to have access to them? 

1) be in the network to access the internal port ( n8n container is on the server that the services are running) ( for our whitlist devices we use zerotier vpn ( see "server set up first (Do first) for vpn self hosting ))

2) be whitlisted from nginx

3) be whitlisted from firewall ( ufw )

4) edit the device (n8n container or other devices from vpn) /etc/hosts 
                                                                                                       
                                                                                                                                   
                                                                                                                                
