var kafka = require("kafka-node"),
    Consumer = kafka.Consumer,
    client = kafka.Client(),
    consumer = new Consumer(client,
        [
          { topic: "orders", partition: 0 }
        ],
        {
          autocommit: false
        });

consumer.on("message", function(message) {
  console.log(message);
});
