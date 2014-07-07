assert = require("assert")
Handler = require("../src/fetchka").FetchKaHandler

describe 'FetchKaHandler.Builder', ->
  describe 'build', ->
    it 'should return a empty handler', ->
      handler = new Handler.Builder().build()
      assert.equal null, handler._topic

    it 'should have \'orders\' topic', ->
      handler = new Handler.Builder()
        .setTopic("orders")
        .build()
      assert.equal 'orders', handler.topic

    it 'should have the passed in onMessage method', ->
      fake = ->
        @
      handler = new Handler.Builder()
        .setOnMessage(fake)
        .build()
      assert.equal fake, handler.onMessage
