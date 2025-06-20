CREATE TABLE source_topic
(
    `text` STRING
) WITH (
      'connector' = 'kafka',
      'topic' = 'lineage-test-topic-json',
      'properties.bootstrap.servers' = 'kafka:9094',
      'properties.group.id' = 'flink-lineage-test-group',
      'scan.startup.mode' = 'earliest-offset',
      'format' = 'json'  -- Changed from avro-confluent to json
      );