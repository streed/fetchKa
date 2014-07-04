FetchKaConsumerBuilder = require("./fetchKa/utils/fetchka.coffee").FetchKaConsumerBuilder
FetchKaHandlerBuilder = require("./fetchKa/utils/fetchka.coffee").FetchKaHandlerBuilder

onMessage = (message) ->
  console.log "builder", message
handler = new FetchKaHandlerBuilder()
                  .addTopic("orders")
                  .addOnMessage(onMessage)
                  .build()

console.log handler

consumer = new FetchKaConsumerBuilder()
                  .addTopic("orders")
                  .connectString("localhost:2181/kafka0.8")
                  .build()
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

