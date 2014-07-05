fetchka = require("../fetchka.coffee")
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
console.log handler
consumer
  .register(handler)
  .register({
    topic: "orders"
    onMessage:((data) ->
      console.log "hash", data
    ),
    onError:((err) ->
      console.log err
    )})
  .start()
