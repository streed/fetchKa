FetchKaConsumer = require("../fetchKa/fetchka.coffee").FetchKaConsumer
FetchKaHandler = require("../fetchKa/fetchka.coffee").FetchKaHandler

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

consumer.register(handler).start()

