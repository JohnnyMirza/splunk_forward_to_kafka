CREATE SOURCE CONNECTOR SYSLOG_TCP WITH (
  'connector.class' =  'io.confluent.connect.syslog.SyslogSourceConnector',
  'kafka.topic' =  'splunk-syslog-tcp',
  'confluent.topic.bootstrap.servers' =  'broker = 29092',
  'topic' = 'splunk-syslog-tcp',
  'producer.interceptor.classes' =  'io.confluent.monitoring.clients.interceptor.MonitoringProducerInterceptor',
  'value.converter' =  'org.apache.kafka.connect.json.JsonConverter',
  'value.converter.schemas.enable' =  'false',
  'syslog.listener' =  'TCP',
  'syslog.port' =  '5555',
  'tasks.max' =  '1'
);

CREATE STREAM SPLUNK (
    rawMessage VARCHAR
  ) WITH (
    KAFKA_TOPIC='splunk-syslog-tcp',
    VALUE_FORMAT='JSON'
  );

CREATE STREAM SPLUNK_META AS SELECT SPLIT_TO_MAP(rawMessage, '||', '=') PAYLOAD
FROM SPLUNK
EMIT CHANGES;


CREATE STREAM TOHECWITHSPLUNK AS SELECT
  SPLUNK_META.PAYLOAD['sourcetype'] `sourcetype`,
  SPLUNK_META.PAYLOAD['source'] `source`,
  SPLUNK_META.PAYLOAD['time'] `time`,
  SPLUNK_META.PAYLOAD['event'] `event`,
  SPLUNK_META.PAYLOAD['host'] `host`
FROM SPLUNK_META SPLUNK_META
EMIT CHANGES;

CREATE STREAM NETFLOW_ELASTICSEARCH AS SELECT * FROM  TOHECWITHSPLUNK 
WHERE `sourcetype`='cp_zeek_conn'
EMIT CHANGES;

CREATE STREAM DNS_SPLUNK AS SELECT * FROM  TOHECWITHSPLUNK 
WHERE `sourcetype`='cp_zeek_dns'
EMIT CHANGES;

CREATE SINK CONNECTOR SPLUNKSINK WITH (
  'connector.class' = 'com.splunk.kafka.connect.SplunkSinkConnector',
  'topics' =  'DNS_SPLUNK'
  'splunk.hec.uri'  = 'http://192.168.1.101:8089',
  'splunk.hec.token' = '3bca5f4c-1eff-4eee-9113-ea94c284478a',
  'value.converter' = 'org.apache.kafka.connect.storage.StringConverter',
  'confluent.topic.bootstrap.servers' = 'kafka:9092',
  'splunk.hec.json.event.formatted' =  'true',
  'tasks.max' =  '1'
);


CREATE SINK CONNECTOR SINK_ELASTIC_01 WITH (
  'connector.class' = 'io.confluent.connect.elasticsearch.ElasticsearchSinkConnector',
  'connection.url'  = 'http://elasticsearch:9200',
  'key.converter'   = 'org.apache.kafka.connect.storage.StringConverter',
  'value.converter' =  'org.apache.kafka.connect.json.JsonConverter',
  'type.name'       = '_doc',
  'errors.tolerance' = 'all',
  'topics'          = 'NETFLOW_ELASTICSEARCH',
  'key.ignore'      = 'true',
  'schema.ignore'   = 'false'
);



