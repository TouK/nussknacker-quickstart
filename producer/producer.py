import random
import time
from datetime import datetime, timedelta
from time import sleep

from confluent_kafka import Producer
from confluent_kafka.schema_registry import SchemaRegistryClient
from confluent_kafka.schema_registry.avro import AvroSerializer
from confluent_kafka.serialization import SerializationContext, MessageField


schema_registry_conf = {'url': 'http://localhost:3082'
                        }


producer_config = {
    "bootstrap.servers": "localhost:3032",

}

topic = 'cdrs'
SLEEP_INTERVAL = 0.001

def create_event(duration, source_msisdn, destination_msisdn, start_time):
    return {
        'duration': duration,
        'caller_number': source_msisdn,
        'called_number': destination_msisdn,
        'connect_time': start_time
    }


def get_random_msisdn_from_our_client_base():
    generated_msisdn = random.randrange(100000000, 999999999, 1)
    while generated_msisdn % 3 == 0:
       generated_msisdn = random.randrange(100000000, 999999999, 1)
    return "48"+str(generated_msisdn)


def create_random_event():
    duration = random.randrange(1, 600, 1)
    source_msisdn = get_random_msisdn_from_our_client_base()
    destination_msisdn = "48"+str(random.randrange(100000000, 999999999, 1))
    start_time = int((datetime.now() - timedelta(seconds=duration)).timestamp())
    return create_event(duration, source_msisdn, destination_msisdn, start_time)


def delivery_report(original_msg, err, msg):
    """
    Reports the failure or success of a message delivery.

    Args:
        err (KafkaError): The error that occurred on None on success.

        msg (Message): The message that was produced or failed.

    Note:
        In the delivery report callback the Message.key() and Message.value()
        will be the binary format as encoded by any configured Serializers and
        not the same object that was passed to produce().
        If you wish to pass the original object(s) for key and value to delivery
        report callback we recommend a bound callback or lambda where you pass
        the objects along.
    """

    if err is not None:
        print("Delivery failed for User record {}: {}".format(msg.key(), err))
        return
    # print('Record {} successfully produced to {} [{}] at offset {}'.format(
    #     original_msg, msg.topic(), msg.partition(), msg.offset()))


if __name__ == '__main__':
    schema_registry_client = SchemaRegistryClient(schema_registry_conf)
    transactions_schema = schema_registry_client.get_latest_version(topic + '-value')
    avro_serializer = AvroSerializer(schema_registry_client, transactions_schema.schema)
    producer = Producer(producer_config)
    print("Producing records to topic {}. ^C to exit.".format(topic))
    while True:
        # Serve on_delivery callbacks from previous calls to produce()
        producer.poll(0.0)
        try:
            event = create_random_event()
            # print("Producing {}".format(event))
            producer.produce(topic=topic,
                             value=avro_serializer(event, SerializationContext(topic, MessageField.VALUE)),
                             on_delivery=lambda err, msg: delivery_report(event, err, msg))
        except KeyboardInterrupt:
            break
        except ValueError:
            print("Invalid input, discarding record...")
            continue
        sleep(SLEEP_INTERVAL)

    print("\nFlushing records...")
    producer.flush()
