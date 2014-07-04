var kafka = require("kafka-node"),
    Producer = kafka.Producer,
    client = new kafka.Client(),
    producer = new Producer(client);

var sys = require("sys");
var stdin = process.openStdin();

var payloads = [
  { topic: "orders", messages: "yay", partition: 0 },
  { topic: "orders", messages: "yay2", partition: 0 }
];

producer.createTopics(["orders"], false, function(err, data) {
  console.log(data);
});

producer.on('ready', function() {
  producer.send(payloads, function( err, data ) {
    console.log(data);
  });
});

stdin.addListener("data", function(d) {
  producer.send([{topic: "orders", messages:d.toString().substring(0, d.length-1), partition: 0}], function(err, data) {
    console.log(data);
  });
});
