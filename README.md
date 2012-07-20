HALB, the High Availability Load Balancer gem {<img src="https://secure.travis-ci.org/TeamIguana/halb.png" alt="Build Status" />}[http://travis-ci.org/TeamIguana/halb]
====================

It provides Ruby classes to control the maintenance state of machines behind HA.D/LDirector/LVS Load Balancers.

In the future we are planning to provide also integration with Capistrano.

How it works
============
HA.D has a /etc/ha.d/maintenance directory where a file name 'serverx' says that serverx is in maintenance mode and thus must be removed as soon as possible from production.
This gem manages the maintenace mode of servers using this kind of load balancers enabling smooth deploys without downtime.
