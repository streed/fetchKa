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
