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
