FetchKaConsumer = require("./fetchKa/utils/fetchka.coffee").FetchKaConsumer
FetchKaHandler = require("./fetchKa/utils/fetchka.coffee").FetchKaHandler

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
console.log consumer

consumer.register(
  new class
    constructor: () ->
      @topic = "orders"

    onMessage: (message) ->
      console.log message

    onError: (err) ->
      console.log err
).register(
  new class
    constructor: () ->
      @topic = "orders"
    onMessage: (message) ->
      console.log "yay", message

    onError: (err) ->
      console.log "bleh"
).register(handler).start()

