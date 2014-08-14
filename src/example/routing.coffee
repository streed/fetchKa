FetchKa = require "../fetchka"
FetchKaRouting = FetchKa.FetchKaRouting
FetchKaHandler = FetchKa.FetchKaHandler
FetchKaConsumer = FetchKa.FetchKaConsumer

databases = {
  save: (data) ->
    console.log "Saving", data
}

payments = {
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
      databases.save data
    ),
    onError:((err) ->
      LOG.error err
    )
  }).build()

payment = FetchKaHandler.Builder()
  .set({
    topic: "orders"
    onMessage:((data) ->
      payments.charge data
    ),
    onError:((err) ->
      LOG.error err
    )
  }).build()

email = FetchKaHandler.Builder()
  .set({
    onMessage:((data) ->
      emailService.send data
    ),
    onError:((err) ->
      LOG.error err
    )
  }).build()

driver = FetchKaHandler.Builder()
  .set({
    onMessage:((data) ->
      driverService.find data
    ),
    onError:((err) ->
      LOG.error err
    )
  }).build()

routing = FetchKaRouting.Builder("orders")
  .routing [ db, [ email, [ payment, driver ] ] ]
  .build()

consumer = new FetchKaConsumer.Builder()
  .addTopic("orders")
  .connectString("localhost:2181")
  .build()

consumer.register(routing).start()

