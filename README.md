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

Sometimes transactions are required and messages must be consumed in steps rather than seperate from other handlers. For example below we have some typical handlers; `db`, `payment`, `email`, and `driver`. These should work together 
so that the actions occur in the proper order and only if the proceeding action successfully completes.

```coffeescript
FetchKa = require("../fetchKa/fetchKa")
FetchKaRouting = FetchKa.FetchKaRouting
FetchKaHandler = FetchKa.FetchKaHandler
FetchKaConsumer = FetchKa.FetchKaConsumer

databases = {
  save: (data) ->
    console.log "Saving", data
}

payment = {
  charge: (data) ->
    console.log "Charging", data
}

emailService = {
  send: (data) ->
    console.log "Sending email to", data
}

driverService = {
  find: (data) ->
    console.log "Finding a driver for", data
}

db = FetchKaHandler.Builder()
  .set({
    topic: "orders"
    onMessage:((data) ->
      database.save data
    ),
    onError:((err) ->
      LOG.error err
    )
  }).build()

payment = FetchKaHandler.Builder()
  .set({
    topic: "orders"
    onMessage:((data) ->
      payment.charge data
    ),
    onError:((err) ->
      LOG.error err
    )
  }).build()

email = FetchHandler.Builder()
  .set({
    onMessage:((data) ->
      emailService.send data
    ),
    onError:((err) ->
      LOG.error err
    )
  }).build()

driver = FetchHandler.Builder()
  .set({
    onMessage:((data) ->
      driverService.find data
    ),
    onError:((err) ->
      LOG.error err
    )
  }).build()

routing = FetchKaRouting.Builder("order")
  .routing [ db, [ payment, [ email, driver ] ] ]
  .build()

consumer = new FetchKaConsumer.Builder()
  .addTopic("orders")
  .connectString("localhost:2181/kafka0.8")
  .build()

consumer.register(routing).build()).start()

```
The above example will create two handlers with the following relationship.

```
    "order": ε
         |
         db
         |
      payment
      /     \
   email   driver
```

The above creates a sequence of handlers within the message routing. The two branches are identical until after the `payment` handler handler has finised and it will split to two different branches. 

One other thing to note is that handlers at the same level are seperate from each other meaning that if one of them fails the others in the same level will try still possibly succeed. 


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
