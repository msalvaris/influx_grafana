.ONESHELL:
SHELL := /bin/bash

define PROJECT_HELP_MSG
Usage:
	make help                           show this message
	make run							start influx container and grafana container
	make stop							stop all containers
	make start							restart all stopped containers
	make clean							stop and remove all containers, delete data and docker images
endef
export PROJECT_HELP_MSG

INFLUXDB_DB?=gpudata
INFLUXDB_USER?=admin
INFLUXDB_USER_PASSWORD?=password
GF_ADMIN_PASSWORD?=secret

INFLUX_DB_PORT?=8083
GF_PORT?=3000
INFLUXDB_LOCATION?=$(PWD)

help:
	@echo "$$PROJECT_HELP_MSG" | less

run: influx grafana
	@echo "InfluxDB and Grafana started"
	@echo "Influx DB $(INFLUXDB_DB) set up waiting on port $(INFLUX_DB_PORT)"
	@echo "Grafana set up and waiting on port $(GF_PORT)"


influx:
	docker run -d -p $(INFLUX_DB_PORT):$(INFLUX_DB_PORT) -p 8086:8086 \
	-e INFLUXDB_DB=$(INFLUXDB_DB) \
	-e INFLUXDB_USER=$(INFLUXDB_USER) \
	-e INFLUXDB_USER_PASSWORD=$(INFLUXDB_USER_PASSWORD) \
	-v $(INFLUXDB_LOCATION):/var/lib/influxdb \
	-e INFLUXDB_ADMIN_ENABLED=true \
	--name influxdb \
	influxdb
	@echo "Influx DB $(INFLUXDB_DB) set up waiting on port $(INFLUX_DB_PORT)"


grafana:
	# create /var/lib/grafana as persistent volume storage
	docker run -d -v /var/lib/grafana --name grafana-storage busybox:latest

	# start grafana
	docker run \
	  -d \
	  -p $(GF_PORT):$(GF_PORT) \
	  --name=grafana \
	  --volumes-from grafana-storage \
	  --link influxdb:influxdb \
	  -e GF_SECURITY_ADMIN_PASSWORD=$(GF_ADMIN_PASSWORD) \
	  -e "GF_INSTALL_PLUGINS=grafana-azure-monitor-datasource,briangann-gauge-panel,natel-plotly-panel" \
	  grafana/grafana
	@echo "Grafana set up and waiting on port $(GF_PORT)"

start:
	docker start influxdb grafana-storage grafana

stop:
	docker stop influxdb grafana-storage grafana

clean: stop delete
	docker rm -v influxdb grafana-storage grafana

delete:
	rm -r data meta wal

remove: clean
	docker rmi influxdb grafana/grafana


.PHONY: help run
