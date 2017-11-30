.ONESHELL:
SHELL := /bin/bash

define PROJECT_HELP_MSG
Usage:
	make help                           show this message
endef
export PROJECT_HELP_MSG


help:
	@echo "$$PROJECT_HELP_MSG" | less

run: influx grafana
	@echo "InfluxDB and Grafana started"


influx:
	docker run -d -p 8083:8083 -p 8086:8086 \
	-e INFLUXDB_DB="gpudata" \
	-e INFLUXDB_USER="masalvar" \
	-e NFLUXDB_USER_PASSWORD="password" \
	-v $(PWD):/var/lib/influxdb \
	-e INFLUXDB_ADMIN_ENABLED=true \
	--name influxdb \
	influxdb


grafana:
	# create /var/lib/grafana as persistent volume storage
	docker run -d -v /var/lib/grafana --name grafana-storage busybox:latest

	# start grafana
	docker run \
	  -d \
	  -p 3000:3000 \
	  --name=grafana \
	  --volumes-from grafana-storage \
	  --link influxdb:influxdb \
	  -e GF_SECURITY_ADMIN_PASSWORD=secret \
	  grafana/grafana

.PHONY: help
