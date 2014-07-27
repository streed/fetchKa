assert = require("assert")
Consumer = require("../src/fetchka").FetchKaConsumer
Handler = require("../src/fetchka").FetchKaHandler

makeHandler = () ->
  fake = ->
    @
  h = new Handler.Builder()
    .setTopic("orders")
    .setOnMessage(fake)
    .build()

  return h

describe 'FetchKaConsumer.Builder', ->
  describe 'build', ->
    it 'should return a empty Consumer', ->
      builder = new Consumer.Builder()
      consumer = builder.build()
      assert.deepEqual {}, consumer._listeners
    
    it 'should return a Consumer with the passed in handler', ->
      handler = makeHandler()
      consumer = new Consumer.Builder()
        .addTopic("orders")
        .build()
      consumer.register handler
      assert.deepEqual {orders:[handler]}, consumer._listeners
