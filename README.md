# About this repository
## What's the purpose of this repository?
It's a POC demonstrating how can you integrate Flink 2.0 with DataHub using OpenLineage, in order to visualize 
Stream Lineage graph. It's extremely minimalistic - just the bare minimum necessary to see the graph. The 
only unnecessary part is the Schema Registry, but I'm leaving it in. Hopefully it will be useful - it's integrated
with Kafka UI and Datahub using environment variables.

## What's in this repository?
All deployed locally using Docker Compose

### Kafka
- Kafka 4.0
- Kafka UI
- Schema Registry
- Kafka Rest Proxy

### Flink 2.0
- Flink jobmanager

Jobmanager has Sql Gateway enabled, so it's easier to submit FlinkSQL jobs programmatically.
- Flink taskmanager
- Custom openlineage-flink jar and other necessary jars in ./flink-jars.

### Datahub
- Basic setup based on https://github.com/datahub-project/datahub/blob/master/docker/quickstart/docker-compose.quickstart.yml

### request-logger-proxy
This is a simple ngingx proxy that forwards all incoming requests to datahub-gms, but also logs them to the console.
Because Datahub supports OpenLineage through a http enpoint only, this is very helpful when debugging OpenLineage. 

## How to run it?
1. Run docker-compose with env variables from .env file
```bash
  docker-compose --env-file .env up
```
2. Once everything is up, run the scripts that will result in creation of two kafka topics:
```bash
  ./scripts/send-kafka-message.sh
  ./scripts/submit-flinksql-job.sh
```
3. To validate that everything is working, validate in Kafka UI (`localhost:8090`) that the following topics were 
created and both contain at least one message:
- lineage-test-topic-json
- lineage-test-topic-json-flinkoutput
4. Ingest Kafka metadata in Datahub:
- Log into Datahub UI (`localhost:9002`), credentials datahub/datahub
- Data Sources -> Create new source -> Kafka
  - Screen 2: 
    - Bootstrap servers: kafka:9094
    - Schema Registry URL: http://schema-registry:8081
  - Screen 4:
    - Name: Kafka local (or whatever you want)
After that you can click Save & Run. This will ingest metadata from Kafka topics and Schema Registry. 
Once it's done (takes ~15 seconds), you should be able to see the topics in Datahub UI. In the main scree on the top is
the search bar. Type nothing and click enter. You should see ~10 kafka topics.
  
5. Now that your topics are present, cancel the Flink job through the UI 
(localhost:8082 -> Running Jobs -> select the running job -> Cancel Job)
- Submit the FlinkSQL job again using the script:
```bash
  ./scripts/submit-flinksql-job.sh
```
The job will consume the already published message, but this time when the Lineage Events are sent to Datahub, the Kafka metadata 
is already there - and you should be able to see the Stream Lineage graph in Datahub UI.

6. View the Lineage Graph in DataHub:
- Open Datahub UI (`localhost:9002`)
- Search for the topic `lineage-test-topic-json`
- Click on the Lineage tab

This is what you should see:

<img src="resources/lineage-graph-image.png" alt="Lineage Graph" width="70%">

## Custom-built openlineage-flink jar

This project contains a custom-built openlineage-flink jar containing a bugfix that makes it possible. Hopefully it's merged
to OpenLineage soon.

Code it's built from is published on Github as a PR to the OpenLineage project:
https://github.com/OpenLineage/OpenLineage/pull/3799
