assert = require("assert")
Routing = require("../src/fetchka").FetchKaRouting
Handler = require("../src/fetchka").FetchKaHandler

makeHandler = (name) ->
  h = new Handler.Builder()
      .set({
        topic: "orders"
        name: name
        onMessage:((data) ->
          @counter++
        ),
        onError:((err) ->
          console.log err
        ),
      })
      .build()

  return h

describe 'FetchKaRouting', ->
  describe 'addRouting', ->
    it 'should create the routing tree', ->
      routing = new Routing.Builder("test").routing([1, [ 2, 3 ]]).build()

      assert.deepEqual [{"handler": 1}], routing.level
      assert.deepEqual [{ "topic": "test", "level": [{"handler": 2}, {"handler": 3}], "next": []}], routing.next

    it 'should call all of the handlers in the routing', ->
     h = makeHandler "test1"
     h1 = makeHandler "test2"
     h2 = makeHandler "test3"
     h3 = makeHandler "test4"

     routing = new Routing.Builder("test").routing([h, [h1, h2, [h3]]]).build()

     routing.onMessage "test"

     assert.equal 1, h.counter
     assert.equal 1, h1.counter
     assert.equal 1, h2.counter
     assert.equal 1, h3.counter
