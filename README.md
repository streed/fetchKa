fetchKa
=======

This library is designed to make working with Kafka simpler, even though it is already rediculously easy to use with
the kafka-node library that this code wraps. What we have added is the idea of filter messages through small, simple,
and consise handlers. These handlers can take the message and process it in any manner they see fit. 

For example in a webshop use case we need to receive orders and many different things must be done for each order.

1. The order must be saved to the database.
2. A email must be created to become the client's invoice and have this invoice emailed.
3. A customer-service representative must receive the order within our order handling service.

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

License
=======

The MIT License (MIT)

Copyright (c) 2014 Sean Reed

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.
