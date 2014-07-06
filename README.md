fetchKa
=======

This library is designed to make working with Kafka simpler, even though it is already rediculously easy to use with
the kafka-node library that this code wraps. What we have added is the idea of filter messages through small simple
and consise handlers. These handlers can take the message and process it in any manner they see fit. 

For example in Fetch's case we receive orders and many different things must be done for each order.

1. The order must be saved to the database.
2. A email must be created to become the client's invoice and have this invoice emailed.
3. A customer-service representative must receive the order within our order handling service.
4. A drive must be dispatched for the order.

Under the current design we have a RESTful interface that handles these different aspects of code,
but they are highly coupled and as such make the process very centralised. What we wish to do is break the code down
into these handler sets and have very small functions work on each message. 

Enough of why here are some examples of the library.

Consumer
--------

```coffeescript
fetchka = require("../fetchka")
FetchKaConsumer = fetchka.FetchKaConsumer
FetchKaHandler = fetchka.FetchKaHandler

onMessage = (message) ->
  console.log "builder", message

handler = new FetchKaHandler.Builder()
  .setTopic("orders")
  .setOnMessage(onMessage)
  .build()

consumer = new FetchKaConsumer.Builder()
  .addTopic("orders")
  .connectString("localhost:2181/kafka0.8")
  .build()
consumer
  .register(
     new FetchKaHandler.Builder()
      .setTopic("orders")
      .setOnMessage(onMessage)
      .build()
  )
  .register(
    new FetchKaHandler.Builder()
      .set({
        topic: "orders"
        onMessage:((data) ->
          console.log "hash", data
        ),
        onError:((err) ->
          console.log err
        )
      })
      .build())
  .start()
```

And for the corrosponding Producer.

Producer
--------
```coffeescript
FetchKaProducer = require("../fetchKa/fetchka").FetchKaProducer

producer = new FetchKaProducer.Builder()
                .connectString("localhost:2181/kafka0.8")
                .setTopics(["orders"])
                .build()
producer.ready(->
  producer.send([{topic: "orders", messages: "test", partition: 0}], (err, data) ->
    console.log err, data
  )
)
```

It is very simple to create a set of handlers and to publish messages.

In the future we wish to have chained handlers that allow for further processing of messages, as there are cases where a synchronous model of message processing is required where as most cases can be treated as asynchronous.
