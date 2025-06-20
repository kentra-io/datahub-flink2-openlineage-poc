CREATE TABLE sink_topic
(
    `text` STRING
) WITH (
      'connector' = 'kafka',
      'topic' = 'lineage-test-topic-json-flinkoutput',
      'properties.bootstrap.servers' = 'kafka:9094',
      'format' = 'json'  -- Changed from avro-confluent to json
      );