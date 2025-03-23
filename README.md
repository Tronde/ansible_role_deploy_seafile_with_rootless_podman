[Archived] Deploy Seafile with rootless Podman
==============================================

**Note:** This repository has been archived and I do not plan to use this role again anytime soon.

This role deploys Seafile Pro Edition with rootless podman.
It's in an early stage and I cannot guarantee that it's production ready.
I was able to deploy a working instance with it though.

You are allowed to use the Seafile Pro Edition with up to three users for free. Please see the following URLs for reference:

  * [Pricing of Pro Edition license (annual subscription)](https://www.seafile.com/en/product/private_server/)
  * [Installation of Seafile Server Professional Edition](https://manual.seafile.com/docker/pro-edition/deploy_seafile_pro_with_docker/)
  * [Download Seafile Pro Edition](https://customer.seafile.com/downloads/)    

Things that don't work smooth yet
---------------------------------

The seafile container image includes the application and an NGINX webserver. The image is prepared to request Let's Encrypt certficates for transport layer encryption (TLS). This feature however probably won't work with this role as it only publishes Port 80 to the host and I don't bind privileged ports to my containers. Instead I usually use a reverse Proxy for handeling the TLS connections and forward the requests to the application. This is a scenario supported by Seafile.

See [Enabling HTTPS with Nginx](https://manual.seafile.com/deploy/https_with_nginx/) in the project's documentation on how to set up NGINX as reverse proxy for your Seafile Pod.

I use the Seafile Pro Edition as it fits my use case perfectly. I did not test this role with the Seafile Community Edition. It will need some tweaks to use it for the community edition as well.

** Contributions are welcome!** Please reach out to me and let's talk about how to contribute to this role. As I don't have contribution guidelines in place yet it may be good to have a chat prior to sending a pull request. To contact me you could open an issue, reach out on [Mastodon](https://social.anoxinon.de/@Tronde) or write me an email to jkastning+seafile (at) my-it-brain (dot) de.

Requirements
------------

You need a login on docker.seadrive.org to pull the required seafile container image.
The following modules from the containers.podman collection are required to use this role:
  * containers.podman.podman_login
  * containers.podman.podman_image
  * containers.podman.podman_volume
  * containers.podman.podman_pod
  * containers.podman.podman_container

See [documentation of Containers.Podman](https://docs.ansible.com/ansible/latest/collections/containers/podman/index.html) for more information.

Role Variables
--------------

Please see defaults/main.yml for all variables. Since this role is under developemnt the documentation on all variables is to be done. You could use the playbook from tests/test.yml to set the necessary variables to deploy the pod to your localhost.

### Credentials for docker.seadrive.org

~~~
deploy_seafile_with_podman_seafile_user:
deploy_seafile_with_podman_seafile_pass:
deploy_seafile_with_podman_seafile_registry: docker.seadrive.org
~~~

Here go the credentials needed to download the container image for Seafile Edition Pro.

### Container images

Variables to specify the container images to use are specified by the varialbes in the following block:

~~~
deploy_seafile_with_podman_mariadb_image: docker.io/library/mariadb
deploy_seafile_with_podman_memcached_image: docker.io/library/memcached
deploy_seafile_with_podman_elastic_image: >-
  docker.io/seafileltd/elasticsearch-with-ik:5.6.16
deploy_seafile_with_podman_seafile_image: >-
  docker.seadrive.org/seafileltd/seafile-pro-mc
~~~

### Variables for the pod

~~~
deploy_seafile_with_podman_pod_name: seafile
deploy_seafile_with_podman_pod_pid_file: /tmp/seafile_pod_infra.pid
deploy_seafile_with_podman_pod_port: 80
~~~

With these you give the podman-pod(1) a name specify where the conmon pid fiel of the pod is going to be stored. The variable `deploy_seafile_with_podman_pod_port` defines the published port and binds it to some host port. Using the default `80` will bind an unused high host port to port 80 of the pod. Other possible values for this variable are, e.g. `45678:80` which will bind host port 45678 to port 80 of the pod; `127.0.0.1:45678:80` does the same but port 45678 will be accessible from localhost only. I use this setting when service should run behind a reverse proxy like NGINX.

### Persistant storage for your data

The following varables are used to create named volumes where your data is stored persistently.

~~~
# volumes to store persistent data
deploy_seafile_with_podman_mariadb_volume: seafile-db
deploy_seafile_with_podman_elastic_volume: seafile-elastic
deploy_seafile_with_podman_data_volume: seafile-data
~~~

### Variables you usually don't need to change

IMHO the following variables are self-explanatory and don't need to be changed for a successful deployment. Please raise an issue if something is hard to understand. Then the documentation could be improved.

~~~
# variables for mariadb container in seafile pod
deploy_seafile_with_podman_mariadb_container_name: seafile-db
deploy_seafile_with_podman_mariadb_root_pw: 'mysqlrootpw'
deploy_seafile_with_podman_mariadb_log_console: true
deploy_seafile_with_podman_mariadb_pid_file: /tmp/seafile_mariadb.pid

# variables for memcached container in seafile pod
deploy_seafile_with_podman_memcached_container_name: seafile-mamcached
deploy_seafile_with_podman_memcached_pid_file: /tmp/seafile_memcached.pid

# variables for elasticsearch container in seafile pod
deploy_seafile_with_podman_elastic_container_name: seafile-elasticsearch
deploy_seafile_with_podman_elastic_type: single-node
deploy_seafile_with_podman_elastic_memory_lock: true
deploy_seafile_with_podman_elastic_java_opts: -Xms1g -Xmx1g
deploy_seafile_with_podman_elastic_pid_file: /tmp/seafile_elastic.pid
deploy_seafile_with_podman_seafile_container_name: seafile-seafile
deploy_seafile_with_podman_seafile_db_host: 127.0.0.1
deploy_seafile_with_podman_seafile_pid_file: /tmp/seafile_seafile.pid
deploy_seafile_with_podman_seafile_le_cert: false
~~~

### Variables you may want to overwrite

~~~
deploy_seafile_with_podman_seafile_time_zone: 'Europe/Berlin'
deploy_seafile_with_podman_seafile_admin_email:
deploy_seafile_with_podman_seafile_admin_pw: 'ChangeThis11!'
deploy_seafile_with_podman_seafile_hostname: seafile.example.com
~~~

Here you have to:

  * Set your time zone
  * Give an admin email address which will be the username of your admin user
  * Set a uniqe and save admin password
  * Set your domain for your seafile instance

Example Playbook
----------------

---
- hosts: localhost
  remote_user: root
  vars:
    deploy_seafile_with_podman_seafile_user: seafile
    deploy_seafile_with_podman_seafile_pass: 'YourSecretPWgoeshere'
    deploy_seafile_with_podman_seafile_registry: docker.seadrive.org
    deploy_seafile_with_podman_seafile_hostname: seafile.example.com
  roles:
    - ansible_role_deploy_seafile_with_rootless_podman

License
-------

BSD

Author Information
------------------

Joerg Kastning (https://www.my-it-brain.de)
