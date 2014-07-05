FetchKaProducer = require("../fetchKa/fetchka").FetchKaProducer

producer = new FetchKaProducer.Builder()
                .connectString("localhost:2181/kafka0.8")
                .setTopics(["orders"])
                .build()
producer.ready(=>
  producer.send([{topic: "orders", messages: "test", partition: 0}], (err, data) ->
    console.log err, data
  )
)
