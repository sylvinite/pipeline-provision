# Tarzan 

Ansible role for deploying the Kong (https://getkong.org/) API and microservice management layer. 

To be used for e.g. proxying other NGI pipeline web services; adding authentication features etc on top.

TODO: Backup of Cassandra db somehow? Or perhaps unnecessary if we think we can just re-generate the tokens.
TODO: Authentication to Cassandra? Or is it enough that we're running on a secure system? 
TODO: Have serf traffic encrypted? 
TODO: Kong and Serf file perms
