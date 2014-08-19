FetchKaProducer = require("../fetchka").FetchKaProducer

producer = new FetchKaProducer.Builder()
                .connectString("localhost:2181")
                .setTopics(["orders"])
                .build()
producer.ready(->
  for i in [1..10]
    producer.sendOne("orders", {customer: {email: "test@test.com"}}, (err, data) ->
      console.log err, data
    )
)
