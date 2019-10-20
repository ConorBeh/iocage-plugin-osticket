# iocage-plugin-osticket

osTicket is a popular open source ticketing and knowledge base system. 
This iocage plugin will create a jail with php73 (and the required extensions), lighttpd, and mariadb. The database name and credentials are outputted to the terminal if run from the CLI or to the UI (working on it). 

TODO:
Output db credentials to WebUI
Output the command to remove setup after install and set permissions on the config file (or do this automatically?)
