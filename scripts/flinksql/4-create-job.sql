INSERT INTO sink_topic
SELECT `text` || ' - processed by Flink'
FROM source_topic;
