HALB, the High Availability Load Balancer gem 
====================
<img src="https://secure.travis-ci.org/TeamIguana/halb.png" alt="Build Status" />


It provides Ruby classes to control the maintenance state of machines behind HA.D/LVS/LDirector/HAProxy Load Balancers.

In the future we are planning to provide also integration with Capistrano.

How it works
============
This gem can control LDirector or HAProxy loadbalancer to instruct them to put or remove a machine from mantainance mode.

LDirector
======
LDirector has a /etc/ha.d/maintenance directory where a file name 'serverx' says that serverx is in maintenance mode and thus must be removed as soon as possible from production.
This gem manages the maintenace mode of servers using this kind of load balancers enabling smooth deploys without downtime.

HAProxy
======
HAProxy is instructed to put or remove a server from maintenance mode sending a command to it through a socket file.

Example with HAProxy
============
```
loadbalancers = [Halb::HAProxy.new('loadbalancer01.localnet', 'root', SSH_KEY, '10.1.0.33', ['proxy_name_1']),
                    Halb::HAProxy.new('loadbalancer02.localnet', 'root', SSH_KEY, '10.1.0.33', ['proxy_name_1'])]
machines_hash = {'web1.service.localnet' => 'web1_srv', 'web2.service.localnet' => 'web2_srv'}
deploy = Halb::Deploy.with(loadbalancers, machines_hash)
deploy.remove_from_production
Project.new.install
deploy.put_into_production
```
