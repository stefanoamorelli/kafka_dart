import 'package:kafka_dart/kafka_dart.dart';

Future<void> main() async {
  final consumer = await KafkaFactory.createAndInitializeConsumer(
    bootstrapServers: 'localhost:9092',
    groupId: 'dart_consumer_group',
    additionalProperties: {
      'client.id': 'dart_consumer_example',
      'auto.offset.reset': 'earliest',
    },
  );

  try {
    // Subscribe to topics
    await consumer.subscribe(['test-topic']);
    
    print('Consumer subscribed to test-topic, waiting for messages...');

    // Poll for messages with timeout
    while (true) {
      final message = await consumer.pollMessage(
        const Duration(seconds: 1),
      );
      
      if (message != null) {
        print('Received message:');
        print('  Topic: ${message.topic.value}');
        print('  Partition: ${message.partition.value}');
        print('  Key: ${message.key.hasValue ? message.key.value : 'null'}');
        print('  Payload: ${message.payload.value}');
        print('  Timestamp: ${message.timestamp}');
        print('  Offset: ${message.offset}');
        print('---');
        
        // Commit the offset
        await consumer.commitAsync();
      }
    }
  } catch (e) {
    print('Error consuming messages: $e');
  } finally {
    await consumer.close();
  }
}

// Alternative example using message stream
Future<void> streamExample() async {
  final consumer = await KafkaFactory.createAndInitializeConsumer(
    bootstrapServers: 'localhost:9092',
    groupId: 'dart_stream_group',
  );

  try {
    await consumer.subscribe(['test-topic']);
    
    await for (final message in consumer.messageStream()) {
      print('Stream received: ${message.payload.value}');
      await consumer.commitAsync();
      
      // Break after 10 messages for demo
      if (message.payload.value.contains('Message 9')) {
        break;
      }
    }
  } finally {
    await consumer.close();
  }
}