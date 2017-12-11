# Influx + Grafana

make run INFLUXDB_DB=gpudata INFLUXDB_USER=admin INFLUXDB_USER_PASSWORD=password GF_ADMIN_PASSWORD=secret


https://davidanguita.name/articles/simple-data-visualization-stack-with-docker-influxdb-and-grafana/

https://hub.docker.com/r/grafana/grafana/

https://hub.docker.com/_/influxdb/

https://blog.laputa.io/try-influxdb-and-grafana-by-docker-6b4d50c6a446

pip install -e git+https://github.com/msalvaris/influx_grafana.git

influxdb_gpu_logger.py localhost 8086 masalvar password gpudata --machine=$$(hostname)
