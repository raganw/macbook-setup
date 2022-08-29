# Macbook Setup

## Bootstrap
```shell
curl https://raw.githubusercontent.com/raganw/macbook-setup/main/start.sh | bash
```

## Ongoing update
```shell
cd ~/Developer/macbook-setup
ansible-playbook -i inventory local.yml
```
