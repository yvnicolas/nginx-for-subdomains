# nginx-for-subdomains
Assume you want to run several web applications/service on the same server. Each of the applications runs in a separate
container and you want to have a redirection for every application by subdomain.
* myfirstapp.mydomain.com will access myfirstapp
* myotherapp.mydomain.com will access myotherapp

This is aimple set up using nginx to automatically root to the app to the right container based on subdomains of the url linked to container names.

It also takes care of making sure the access is only https if you want.


# Usage
Update `configxxx/subdomains.conf` server part with your domain name.

Update `configxxx/subdomains.conf` with the port mapping of your services.

If your are running in ssl configuration, create a key directory where you put your certificate in it and check the key location directif in `config/include/ssl.conf`

Create a network for the containers accessible for nginx

```
docker network create nginx-net
```

Start nginx with right links, dependant on what config you choose.

* For configuration with ssl :     
```
docker run -d --name nginx-main --network nginx-net -v $(pwd)/config:/etc/nginx/conf.d:ro -v $(pwd)/pages:/usr/share/nginx/html:ro  -v $(pwd)/keys:/etc/nginx/keys:ro -p 80:80 -p 443:443 nginx
```    
* For configuration without ssl :
```
docker run -d --name nginx-main --network nginx-net -v $(pwd)/config-nossl:/etc/nginx/conf.d:ro -v $(pwd)/pages:/usr/share/nginx/html:ro -p 80:80 nginx
```

Start a service
* start the container
* connect the container in the nginx network with the alias right service name.
