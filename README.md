This app is a set custom inputs/transforms that allows you to send "pre-cooked" data to apache kafka. A Splunk Heavy Forwarder is requires and to install the app follow the below instructions:
* unzip 'splunk_forward_to_kafka.zip' to the $SPLUNK_HOME/etc/apps/ dirctory; or
* copy the props.conf/transforms.conf to an app of your choice
* set forwarding to kafka e.g
  [tcpout:third_party]
  *server = kafka_connect:port
  *sendCookedData = false
* Check the props.conf for more instructions on what data you want to forward. Everything is commented out by default
* I tested with confluent syslog connector e.g. above kafka_connect:port. refer to this link to install https://docs.confluent.io/current/connect/kafka-connect-syslog/index.html
* restart splunk

## Next steps
### Filter data using KSQL
### Confluent Kafka/Splunk Sink Connector https://docs.confluent.io/current/connect/kafka-connect-syslog/index.htm


## Additional Info
### To learn more about Splunk queues, refer to this link https://wiki.splunk.com/Community:HowIndexingWorks
### Potentially look at Netty Connector
### Potentially look at Zeek for listening to TCP Port
