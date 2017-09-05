# nginx-for-subdomains
Assume you want to run several web applications/service on the same server. Each of the applications runs in a separate
container and you want to have a redirection for every application based on the url call.
* myfirstapp.mydomain.com will access myfirstapp container
* myotherapp.yourdomain.net will access myotherapp container

This is aimple set up using nginx to automatically root to the app to the right container based on subdomains of the url linked to container names.

It also takes care of making sure the access is only https if you want.


# Usage

Update `config/variables.conf` with the port mapping of your services.

If your are running in ssl configuration,
* create a key directory where you put your certificate in it
* check the key location directif in `config/include/ssl.conf`
* delete `config/nohttpsredir.conf` file

If not, delete `config/nohttpsredir.conf`


Create a network for the containers accessible for nginx

```
docker network create nginx-net
```

Start nginx with right links :     
```
docker run -d --name nginx-main --network nginx-net -v $(pwd)/config:/etc/nginx/conf.d:ro -v $(pwd)/pages:/usr/share/nginx/html:ro  -v $(pwd)/keys:/etc/nginx/keys:ro -p 80:80 -p 443:443 nginx
```    
_you do not need the 443 port mapping if you do not use ssl redirection_

Start a service
* start the container
* connect the container in the nginx network with the alias right service name.

Example    
You want to launch a blog service under the Url `blog.mydomain.com`. You have a blog application developped which is exposed on port 8544.
Your variables.conf file should look like :
```
map $host $port {
    default 80;
    # Add all available servers here
    blog.mydomain.com 8544;
}


map $host $container {
    default none;

    # Add all available servers here
    blog.mydomain.com blogapp;
}

```
The container for you blog app has been launched using
```
docker run -d --name 20170905-blog-v2 blogimage
docker network connect --alias blogapp nginxnet 20170905-blog-v2
````
