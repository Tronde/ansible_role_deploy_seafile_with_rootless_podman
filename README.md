Deploy Seafile with rootless Podman
===================================

This role attempts to deploy seafile with rootless podman. But unfortunately it doesn't work yet.

Requirements
------------

You need a login on docker.seadrive.org to pull the required seafile container image.
The following modules from the containers.podman collection are required to use this role:
  * containers.podman.podman_login
  * containers.podman.podman_image
  * containers.podman.podman_volume
  * containers.podman.podman_volume
  * containers.podman.podman_pod
  * containers.podman.podman_container
  * containers.podman.podman_container
  * containers.podman.podman_container
  * containers.podman.podman_container

Role Variables
--------------

Please see defaults/main.yml for all variables. Since this role is under developemnt the documentation on all variables is to be done. You could use the playbook from tests/test.yml to set the necessary variables to deploy the pod to your localhost.

Dependencies
------------

A list of other roles hosted on Galaxy should go here, plus any details in regards to parameters that may need to be set for other roles, or variables that are used from other roles.

Example Playbook
----------------

Including an example of how to use your role (for instance, with variables passed in as parameters) is always nice for users too:

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
