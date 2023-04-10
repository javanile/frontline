
include .env
export $(shell test -f .env && cut -d= -f1 .env)

## ======
## Deploy
## ======

ssh:
	@sshpass -p $${SSH_PASSWORD} ssh $${SSH_USER}@${SSH_HOST} -p $${SSH_PORT:-22} bash -s -- $${SSH_PASSWORD}

deploy:
	@date > contrib/RELEASE
	@git add .
	@git commit -am "Deploy"
	@git push
	@cat contrib/deploy.sh | make -s ssh

restart:
	@docker compose pull
	@docker compose up -d --force-recreate --remove-orphans && sleep 15
	@docker compose logs proxy

expose-docker:
	@echo '{"hosts": ["tcp://0.0.0.0:2375", "unix:///var/run/docker.sock"]}' > /etc/docker/daemon.json
	@mkdir -p /etc/systemd/system/docker.service.d
	@printf "[Service]\nExecStart=\nExecStart=/usr/bin/dockerd\n" > /etc/systemd/system/docker.service.d/override.conf
	@systemctl daemon-reload
	@systemctl restart docker.service

## =====
## Tests
## =====

test:
	@docker compose up -d
	@docker compose exec mysql printenv

test-remote-create-database:
	@MYSQL_PWD=secret mysql -h $${SSH_HOST} -u root < lib/create_database.sql
	@MYSQL_PWD=secret mysql -h $${SSH_HOST} -u root -e "USE mysql; CALL create_database(ciccio, ciccio)"