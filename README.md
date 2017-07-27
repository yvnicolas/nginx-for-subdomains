# nginx-for-subdomains
Assume you want to run several web applications/service on the same server. Each of the applications runs in a separate
container and you want to have a redirection for every application by subdomain.
* myfirstapp.mydomain.com will access myfirstapp
* myotherapp.mydomain.com will access myotherapp

This is aimple set up using nginx to automatically root to the app to the right container based on subdomains of the url linked to container names.

It also takes care of making sure the access is only https if you want.


# Usage

You first need to create the network

Start nginx with right links, dependant on what config you choose

Start a service
* start the container
* connect the container in the nginx network with the alias right service name.
