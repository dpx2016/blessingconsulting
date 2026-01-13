
# Odoo Ansible (Hetzner Cloud)

This repository contains Ansible playbooks, roles and helper files to provision and manage a high-availability Odoo deployment on Hetzner Cloud.

Key components
- ansible.cfg, inventory and production/staging inventories
- Playbooks: deploy.yml, deploy_odoo.yml, deploy_postgres.yml, start.yml, stop.yml, wipe.yml and related tasks
- Roles: organized under roles/ (odoo_instance, postgres, grafana, prometheus, node_exporter, sftpgo, etc.)
- Group variables and vaulted secrets: group_vars/vault.yml
- cloud-init/ and bash/: helper templates and scripts used during provisioning

Quickstart
1. Install Ansible (recommended 2.9+ or as required by requirement.yml) and any dependencies.
2. Populate your inventory: use production/inventory or staging/inventory, or inventory/hosts.ini.
3. Provide secrets in group_vars/vault.yml (or use ansible-vault to edit: ansible-vault edit group_vars/vault.yml).
4. Run a deployment (example):

	ansible-playbook -i production/inventory deploy.yml --ask-become-pass

Common playbooks
- deploy.yml           — full deployment orchestration 
        - to deploy a brand new customer: 
                ansible-playbook -i production deploy.yml -e "target_customers=['customerxx']"
                ansible-playbook -i production init_odoo_db.yml -e "target_customers=['veto']" -e create_db_do=true

- deploy_odoo.yml      — deploy Odoo application instances
    - to deploy or redeploy a already exist customer
            ansible-playbook -i production deploy_odoo.yml  -e "target_customers=['customerxx']"

- deploy_postgres.yml  — provision Postgres database(s)
- start.yml / stop.yml — control services
- wipe.yml             — remove deployments and data (use with caution)
- generate_haproxy_map.yml — build HAProxy mapping from inventory

# Unboard new customer:

    ansible-playbook -i production deploy_customer_db.yml -e "target_customers=['customerxx']" -e create_db_do=true
    ansible-playbook -i production deploy.yml  -e "target_customers=['customerxx']"
    ansible-playbook -i production init_odoo_db.yml -e "target_customers=['customerxx']"
     ansible-playbook -i production stop.yml deploy_customer_db.yml  -e "target_customers=['classic']" -e create_db_do=true


Tips
- Use --limit to target specific hosts or groups.
- Use --tags to run specific tasks from a playbook.
- Review roles/ and templates/ for service configuration and customization.

Support files
- cloud-init/: cloud-init YAMLs to bootstrap servers
- bash/: helper scripts for IPA and SFTP setup

License
This repository does not include a license file. Treat usage according to project owner guidance.


