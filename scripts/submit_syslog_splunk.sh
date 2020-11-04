#!/bin/bash

HEADER="Content-Type: application/json"
DATA=$( cat << EOF
{
  "name": "Splunk-syslog-tcp",
  "config": {
    "connector.class": "io.confluent.connect.syslog.SyslogSourceConnector",
    "kafka.topic": "splunk-syslog-tcp",
    "confluent.topic.bootstrap.servers": "broker:29092",
    "topic":"splunk-syslog-tcp",
    "producer.interceptor.classes": "io.confluent.monitoring.clients.interceptor.MonitoringProducerInterceptor",
    "value.converter": "org.apache.kafka.connect.json.JsonConverter",
    "value.converter.schemas.enable": "false",
    "syslog.listener": "TCP",
    "syslog.port": "5555",
    "tasks.max": "1"
  }
}
EOF
)

curl -X POST -H "${HEADER}" --data "${DATA}" http://localhost:8083/connectors
