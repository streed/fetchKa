Consumer = require("../src/fetchka").FetchKaConsumer
assert = require("assert")

describe 'FetchKaConsumer.Builder', ->
  describe 'build', ->
    it 'should return a empty Consumer', ->
      builder = new Consumer.Builder()
      consumer = builder.build()
      assert.deepEqual {}, consumer._listeners
